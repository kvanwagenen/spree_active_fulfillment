module Spree::Fulfillment::Providers::Amazon
  class CancelFulfillmentOrderRequest < PeddlerRequest
   
    def initialize(fulfillment)
      @seller_fulfillment_order_id = fulfillment.fulfiller_id
    end

    def execute
      client.cancel_fulfillment_order(seller_fulfillment_order_id)
      true
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    attr_reader :seller_fulfillment_order_id
  end
end