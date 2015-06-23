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

    context '#cancel_fulfillment' do
      let(:cancel_fulfillment_order_request) do
        instance_double(CancelFulfillmentOrderRequest, execute: true)
      end
      let(:get_fulfillment_order_request) do
        instance_double(GetFulfillmentOrderRequest, fulfillment_order: fulfillment_order)
      end
      let(:fulfillment_order) do
        instance_double(FulfillmentOrder, cancelled?: true)
      end
      let(:fulfillment){ build(:fulfillment) }
      before(:each) do
        class_double(CancelFulfillmentOrderRequest, new: cancel_fulfillment_order_request).as_stubbed_const
        class_double(GetFulfillmentOrderRequest, new: get_fulfillment_order_request).as_stubbed_const
      end

      context 'with a successful cancellation' do
        before(:each) do
          provider.cancel_fulfillment(fulfillment)
        end

        it 'sends new to CancelFulfillmentOrderRequest' do
          expect(CancelFulfillmentOrderRequest).to have_received(:new).with(fulfillment)
        end

        it 'sends execute to request' do
          expect(cancel_fulfillment_order_request).to have_received(:execute)
        end

        it 'sends new to GetFulfillmentOrderRequest' do
          expect(GetFulfillmentOrderRequest).to have_received(:new).with(fulfillment.fulfiller_id)
        end

        it 'sends fulfillment_order to request' do
          expect(get_fulfillment_order_request).to have_received(:fulfillment_order)
        end

        it 'sends cancelled? to fulfillment_order' do
          expect(fulfillment_order).to have_received(:cancelled?)
        end
      end

      context 'with a failed cancellation' do
        let(:fulfillment_order) do
          double("fulfillment_order", cancelled?: false)
        end

        it 'raises FulfillmentCancellationError' do
          expect{provider.cancel_fulfillment(fulfillment)}.to raise_error(FulfillmentCancellationError)
        end
      end
    end
  end
end