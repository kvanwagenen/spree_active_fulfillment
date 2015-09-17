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