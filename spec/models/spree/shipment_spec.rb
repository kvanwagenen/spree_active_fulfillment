require 'spec_helper'

module Spree
  describe Shipment, type: :model do
    let(:shipment){build(:shipment)}
    before do
      allow(shipment).to receive(:order).and_return(order)
      allow(shipment).to receive(:fulfillment_provider).and_return(fulfillment_provider)
    end
    let(:order){object_double(build(:order))}
    let(:fulfillment_provider){instance_double(Spree::Fulfillment::Providers::Amazon::Provider)}
    let(:fulfillment_service){nil}
    context '#finalize!' do
      before do
        allow(order).to receive(:is_risky?).and_return(risky)
        allow(shipment).to receive(:ship)
      end
      context 'with a risky order' do
        let(:risky){true}
        it 'does not ship' do
          expect(shipment).not_to receive(:ship)
          shipment.finalize!          
        end
      end

      context 'with a safe order' do
        let(:risky){false}
        it 'ships immediately' do
          expect(shipment).to receive(:ship)
          shipment.finalize!
        end
      end     
    end

    context '#after_ship' do
      before do
        allow(shipment).to receive(:orig_after_ship)
        allow(shipment).to receive(:fulfillment_service).and_return(fulfillment_service)
        allow(fulfillment_provider).to receive(:fulfill)
      end
      context 'with a fulfillment provider' do
        it 'triggers fulfillment' do
          expect(fulfillment_provider).to receive(:fulfill).with(shipment, fulfillment_service)
          shipment.after_ship
        end
      end
      context 'without a fulfillment provider' do
        before do
          allow(shipment).to receive(:fulfillment_provider).and_return(nil)
        end
        it 'does not trigger fulfillment' do
          expect(fulfillment_provider).not_to receive(:fulfill)
          shipment.after_ship
        end
      end
    end

    context '#after_cancel' do
      let(:fulfillments){build_list(:fulfillment, 3)}
      before do
        allow(shipment).to receive(:orig_after_cancel)
        allow(shipment).to receive(:fulfillments).and_return(fulfillments)
        fulfillments.each do |fulfillment|
          allow(fulfillment).to receive(:cancel)
        end
      end
      it "cancels each of it's fulfillments" do
        fulfillments.each do |fulfillment|
          expect(fulfillment).to receive(:cancel)
        end
        shipment.after_cancel
      end
    end
  end
end