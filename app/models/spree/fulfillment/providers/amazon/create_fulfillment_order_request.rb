module Spree::Fulfillment::Providers::Amazon
  class CreateFulfillmentOrderRequest < PeddlerRequest
    def fulfillment_order(package, service)
      FulfillmentOrder.new(parsed_response)
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    def parsed_response
      client.create_fulfillment_order()
    end
  end
end