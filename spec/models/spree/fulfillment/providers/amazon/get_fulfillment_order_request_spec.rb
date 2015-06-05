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
      it 'should call get_fulfillment_order on the mws client' do
        request.fulfillment_order
        expect(client).to have_received(:get_fulfillment_order)
      end

      it 'should return an instance of FulfillmentOrder' do
        expect(request.fulfillment_order).to be_instance_of(FulfillmentOrder)
      end
    end
  end
end