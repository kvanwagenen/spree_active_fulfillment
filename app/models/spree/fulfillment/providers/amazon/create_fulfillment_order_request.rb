module Spree::Fulfillment::Providers::Amazon
  class CreateFulfillmentOrderRequest < PeddlerRequest
   
    def initialize(shipment, service)
      @shipment = shipment
      @service = service
    end

    def fulfillment_order_id      
      create_fulfillment_order
      seller_fulfillment_order_id
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    attr_reader :shipment, :service

    def create_fulfillment_order
      client.create_fulfillment_order(
        seller_fulfillment_order_id,
        displayable_order_id,
        displayable_order_date_time,
        displayable_order_comment,
        shipping_speed_category,
        destination_address,
        items,
        options
      )
    end

    def seller_fulfillment_order_id
      "#{shipment.order.number}:#{shipment.number}:#{shipment.fulfillments.length + 1}"
    end

    def displayable_order_id
      shipment.order.number
    end

    def displayable_order_date_time
      shipment.order.completed_at || Time.now
    end

    def displayable_order_comment
      ""
    end

    def shipping_speed_category
      service.to_s.capitalize
    end

    def destination_address
      FbaUtils.amazon_address(shipment.address)
    end

    def items
      shipment.sku_counts.map{|sku_count| create_fulfillment_order_item(sku_count)}
    end

    def create_fulfillment_order_item(sku_count)
      {
        'SellerSKU' => sku_count[:sku],
        'SellerFulfillmentOrderItemId' => "#{shipment.number}:#{sku_count[:sku]}:Q#{sku_count[:count]}",
        'Quantity' => sku_count[:count]
      }
    end

    def options
      {}
    end
  end
end