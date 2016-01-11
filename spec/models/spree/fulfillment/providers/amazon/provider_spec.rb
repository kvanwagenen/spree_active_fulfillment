require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe Provider do
    let(:provider) { Provider.new }

    context "#fulfill" do
      let(:shipment){ create(:shipment) }
      let(:fulfillment){ build(:amazon_fulfillment) }

      before(:each) do
        order_request = double()
        allow(order_request).to receive(:fulfillment_order_id).and_return("an:id")
        fulfillment_order = double()
        allow(fulfillment_order).to receive(:fulfillment).and_return(fulfillment)
        get_fulfillment_request = double()
        allow(get_fulfillment_request).to receive(:fulfillment_order).and_return(fulfillment_order)
        allow(CreateFulfillmentOrderRequest).to receive(:new).and_return(order_request)       
        allow(GetFulfillmentOrderRequest).to receive(:new).and_return(get_fulfillment_request)
        allow(fulfillment).to receive(:handle_status)
      end

      it 'adds a fulfillment to the shipment' do
        provider.fulfill(shipment, :standard)
        fulfillment = shipment.fulfillments.first
        expect(fulfillment).to be_instance_of(Spree::Fulfillment::Providers::Amazon::AmazonFulfillment)
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
      let(:fulfillment){ build(:cancellable_amazon_fulfillment) }
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
      end
    end
    
    context '#update_inventory_levels' do
      let(:variants){create_list(:variant, 5)}
      before do
        variants.first.fulfiller_skus.create(value: "FSKU1")
        variants.first.fulfiller_skus.create(value: "FSKU2")
        variants.second.fulfiller_skus.create(value: "FSKU3")
        sku_levels = [
            
        ]
        # report = double("Spree::Fulfillment::Providers::Amazon::FulfillmentInventorySupply", sku_levels: sku_levels)
        # request = instance_double("Spree::Fulfillment::Providers::Amazon::FulfillmentInventorySupplyRequest", report: report)
        # class_double("Spree::Fulfillment::Providers::Amazon::FulfillmentInventorySupplyRequest").as_stubbed_const(new: )
      end
      it 'includes all of a variants fulfiller skus in the update request' do
        # provider.update_inventory_levels(variants)
        # expect()
      end
    end
  end
end