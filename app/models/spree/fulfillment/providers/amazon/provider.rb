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

    def estimate_delivery_window(package, service, options=nil)
      fulfillment_preview(package, service).delivery_window_estimate(service)
    end

    def update_inventory_levels(variants=nil)
      sku_levels = inventory_report(variants).sku_levels
      variants_updated = []
      sku_levels.each_slice(100) do |sku_level|
        variants = Spree::Variant.includes(:fulfiller_skus).references(:fulfiller_skus).where(fulfiller_skus: {value: sku_levels.map{|sl| sl[:sku]}).where.not(id: variants_updated).distinct
        variants.each do |variant|
          variant_skus = variant.fulfiller_skus.map(&:value) << variant.sku
          on_hand = sku_levels.select{|level|variant_skus.include?(level[:sku])}.inject(0){|sum, level| sum + level[:on_hand]}
          variant.stock_items.find_by_stock_location(amazon_stock_location).try(:set_count_on_hand, on_hand)
        end
        variants_updated = variants_updated | variants.map(&:id)
      end
    end

    def fulfill(shipment, service=nil)
      service ||= shipment_service(shipment)
      fulfillment_order_id = CreateFulfillmentOrderRequest.new(shipment, service).fulfillment_order_id
      fulfillment_order = GetFulfillmentOrderRequest.new(fulfillment_order_id).fulfillment_order
      fulfillment = fulfillment_order.fulfillment
      shipment.fulfillments << fulfillment
      fulfillment.handle_status
    end

    def refresh_fulfillment(fulfillment)
      fulfillment_order = GetFulfillmentOrderRequest.new(fulfillment.fulfiller_id).fulfillment_order
      fulfillment_order.update_fulfillment(fulfillment)
    end

    def cancel_fulfillment(fulfillment)
      if fulfillment.cancellable?
        CancelFulfillmentOrderRequest.new(fulfillment).execute
      else
        fulfillment.refresh
        true
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