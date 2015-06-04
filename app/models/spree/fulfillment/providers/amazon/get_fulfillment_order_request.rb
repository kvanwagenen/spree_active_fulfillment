module Spree::Fulfillment::Providers::Amazon
  class GetFulfillmentOrderRequest < PeddlerRequest

    def initialize(fulfillment_order_id)
      @fulfillment_order_id = fulfillment_order_id
    end

    def fulfillment_order
      FulfillmentOrder.new(parsed_response)
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    attr_reader :fulfillment_order_id

    def parsed_response
      client.get_fulfillment_order(fulfillment_order_id)
    end

  end
end