require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe CreateFulfillmentOrderRequest do
    let(:ship_address){ create(:address) }
    let(:shipment){ create(:shipment) }
    let(:client) do
      client = double("MWS::FulfillmentOutboundShipments::Client")
      allow(client).to receive(:create_fulfillment_order)
      client
    end
    let(:request) do
      request = CreateFulfillmentOrderRequest.new(shipment, :standard) 
      allow(request).to receive(:client).and_return(client)
      request
    end

    before(:each) do
      shipment.address = ship_address
    end

  	context "#fulfillment_order_id" do
      it 'should return a SellerFulfillmentOrderId string' do
        expect(request.fulfillment_order_id).to eq("#{shipment.order.number}:#{shipment.number}:#{shipment.fulfillments.length + 1}")
      end
      it 'should request a fulfillment_order be created via the client' do
        request.fulfillment_order_id
        expect(client).to have_received(:create_fulfillment_order)
      end
  	end
  end
end