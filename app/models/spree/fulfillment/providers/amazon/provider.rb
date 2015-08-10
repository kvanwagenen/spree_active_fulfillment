module Spree::Fulfillment::Providers::Amazon
  class Provider < Spree::Fulfillment::Provider

    def initialize
      @fulfillment_preview_cache = FulfillmentPreviewCache.new
    end
    
    def services
      [:standard, :expedited, :priority]
    end

    def can_fulfill?(package)
      can_fulfill = fulfillment_preview(package, :standard).fulfillable?(:standard)
    end

    def estimate_cost(package, service)
      fulfillment_preview(package, service).total_cost(service)
    end

    def estimate_delivery_window(package, service, ship_date)
      fulfillment_preview(package, service).delivery_window_estimate(service)
    end

    def update_inventory_levels(variants=nil)
      inventory_report(variants).sku_levels.each do |sku_level|
        update_sku_on_hand(sku_level)
      end
    end

    def fulfill(shipment, service=nil)
      service ||= shipment_service(shipment)
      fulfillment_order_id = CreateFulfillmentOrderRequest.new(shipment, service).fulfillment_order_id
      fulfillment_order = GetFulfillmentOrderRequest.new(fulfillment_order_id).fulfillment_order
      shipment.fulfillments << fulfillment_order.fulfillment
    end

    def refresh_fulfillment(fulfillment)
      fulfillment_order = GetFulfillmentOrderRequest.new(fulfillment.fulfiller_id).fulfillment_order
      fulfillment_order.update_fulfillment(fulfillment)
    end

    def cancel_fulfillment(fulfillment)
      CancelFulfillmentOrderRequest.new(fulfillment).execute
      fulfillment_order = GetFulfillmentOrderRequest.new(fulfillment.fulfiller_id).fulfillment_order
      if !fulfillment_order.cancelled?
        raise FulfillmentCancellationError.new "Failed to cancel fulfillment with id #{fulfillment.id} and seller id #{fulfillment.fulfiller_id}"
      end
    end

    private

    attr_accessor :fulfillment_preview_cache

    def shipment_service(shipment)
      shipment.shipping_method.calculator.service
    end

    def fulfillment_preview(package, service)
      preview = fulfillment_preview_cache.get(package, service)
    end

    def fulfillment_config
      Spree::FulfillmentConfig
    end

    def update_sku_on_hand(sku_level)
      stock_item = amazon_stock_location.stock_items.find_by_variant_sku(sku_level[:sku])
      if stock_item && stock_item.count_on_hand != sku_level[:on_hand]
        stock_item.set_count_on_hand(sku_level[:on_hand])
      end
    end

    def amazon_stock_location
      Spree::StockLocation.find(fulfillment_config.preferred_amazon_stock_location_id)
    end

    def inventory_report(variants=nil)
      if variants
        FulfillmentInventorySupplyRequest.new(variants).report
      else
        FbaInventoryReportRequest.new(load_most_recent: fulfillment_config.preferred_load_most_recent_reports).report
      end
    end

  end

  class FulfillmentCancellationError < StandardError; end
end