module Spree::Fulfillment::Providers::Amazon
  class ListAllFulfillmentOrdersRequest < PeddlerRequest

    def initialize(fulfillment_order_id)
      @fulfillment_order_id = fulfillment_order_id
    end

    def fulfillment_order_ids
      parsed_fulfillment_order_ids
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    attr_reader :fulfillment_order_id

    def parsed_response
      client.list_all_fulfillment_orders
    end

    def parsed_fulfillment_order_ids
      parsed_response.css("FulfillmentOrders SellerFulfillmentOrderId").map(&:text)
    end

  end
end