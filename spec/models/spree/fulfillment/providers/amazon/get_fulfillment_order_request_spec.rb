require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe GetFulfillmentOrderRequest do
    let(:client) do
      client = double("MWS::FulfillmentOutboundShipments::Client")
      allow(client).to receive(:get_fulfillment_order)
      client
    end
    let(:request) do
      request = GetFulfillmentOrderRequest.new("") 
      allow(request).to receive(:client).and_return(client)
      request
    end

    context "#fulfillment_order" do
      it 'should return an instance of FulfillmentOrder'
    end
  end
end