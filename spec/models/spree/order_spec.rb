require 'spec_helper'

describe Spree::Order, type: :model do
  let(:order){create(:order_with_line_items)}
  context "#next" do
    context "when state is transitioning to complete" do
      before do
        allow(order).to receive(:payment_required?).and_return(false)
        order.state = "confirm"
        order.save
        order.reload
      end
      context 'when an InventoryNotAvailable error is raised' do
        before do
          allow(order).to receive(:fulfilled_shipments).and_raise(Spree::Fulfillment::Providers::Amazon::InventoryNotAvailable)
        end
        it 'does not transition to complete' do
          expect{order.next}.to raise_error(Spree::Fulfillment::Providers::Amazon::InventoryNotAvailable)
          expect(order.state).to eq("confirm")
        end
      end
      
      context 'when an OnlyStandardServiceAvailableForDestination error is raised' do
        before do
          allow(order).to receive(:fulfilled_shipments).and_raise(Spree::Fulfillment::Providers::Amazon::OnlyStandardServiceAvailableForDestination)
        end
        it 'does not transition to complete' do
          expect{order.next}.to raise_error(Spree::Fulfillment::Providers::Amazon::OnlyStandardServiceAvailableForDestination)
          expect(order.state).to eq("confirm")
        end
      end
      
      context 'when any other error is raised' do
        before do
          allow(order).to receive(:fulfilled_shipments).and_raise(StandardError)
        end
        it 'does not transition to complete' do
          expect{order.next}.to raise_error(StandardError)
          expect(order.state).to eq("confirm")
        end
      end
      
      context 'when no fulfillment error is thrown' do
        before do
          allow(order).to receive(:fulfilled_shipments).and_return([])
        end
        it 'fulfills it\'s shipments' do
          expect{order.next}.not_to raise_error
          expect(order.state).to eq("complete")
        end
      end
      
      context 'when the order has at least one fulfilled and one not fulfilled shipment' do
        let(:fulfilled_shipment) do
          shipment = create(:shipment)
          allow(shipment).to receive(:fulfillment_provider).and_return(Spree::FulfillmentConfig.amazon_provider)
          shipment
        end
        let(:not_fulfilled_shipment) do
          shipment = create(:shipment)
          allow(shipment).to receive(:fulfillment_provider).and_return(nil)
          shipment
        end
        before do
          order.shipments.delete_all
          order.shipments << not_fulfilled_shipment
          order.shipments << fulfilled_shipment
        end
        it 'should fulfill only the fulfilled shipment' do
          expect(fulfilled_shipment).to receive(:fulfill!)
          expect(not_fulfilled_shipment).not_to receive(:fulfill!)
          expect{order.next}.not_to raise_error
        end
      end
    end
  end
end