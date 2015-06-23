require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe CancelFulfillmentOrderRequest do
    let(:fulfillment) { create(:fulfillment) }
    let(:client) do
      instance_double("MWS::FulfillmentOutboundShipments::Client", cancel_fulfillment_order: nil)
    end
    let(:request) do
      request = CancelFulfillmentOrderRequest.new(fulfillment)
      allow(request).to receive(:client).and_return(client)
      request
    end

    context "#execute" do
      it 'returns a boolean value' do
        expect(request.execute).to eq(true)
      end

      it 'requests the fulfillment order be canceled via the client' do
        request.execute
        expect(client).to have_received(:cancel_fulfillment_order).with(fulfillment.fulfiller_id)
      end
    end
  end
end