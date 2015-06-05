require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe Provider do
    let(:provider) { Provider.new }

    context "#fulfill" do
      let(:shipment){ create(:shipment) }
      let(:fulfillment){ build(:fulfillment) }

      before(:each) do
        order_request = double()
        allow(order_request).to receive(:fulfillment_order_id).and_return("an:id")
        fulfillment_order = double()
        allow(fulfillment_order).to receive(:fulfillment).and_return(fulfillment)
        get_fulfillment_request = double()
        allow(get_fulfillment_request).to receive(:fulfillment_order).and_return(fulfillment_order)
        allow(CreateFulfillmentOrderRequest).to receive(:new).and_return(order_request)       
        allow(GetFulfillmentOrderRequest).to receive(:new).and_return(get_fulfillment_request)
      end

      it 'adds a fulfillment to the shipment' do
        provider.fulfill(shipment, :standard)
        fulfillment = shipment.fulfillments.first
        expect(fulfillment).to be_instance_of(Spree::Fulfillment)
        expect(fulfillment.id).not_to be_nil
        expect(fulfillment.fulfiller_id).to eq("an:id")
      end

    end
  end
end