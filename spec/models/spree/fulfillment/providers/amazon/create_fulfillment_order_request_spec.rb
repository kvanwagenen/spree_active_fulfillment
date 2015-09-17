require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe CreateFulfillmentOrderRequest do
    let(:ship_address){ create(:address) }
    let(:shipment){ create(:shipment) }
    let(:request){ CreateFulfillmentOrderRequest.new(shipment, :standard) }
    let(:client){ request.client.client }

    before(:each) do
      shipment.address = ship_address
    end
    
    context "#fulfillment_order_id" do
      before do
        allow(client).to receive(:create_fulfillment_order)
      end
      it 'should return a SellerFulfillmentOrderId string' do
        expect(request.fulfillment_order_id).to eq("#{shipment.order.number}:#{shipment.number}:#{shipment.fulfillments.length + 1}")
      end
      it 'should request a fulfillment_order be created via the client' do
        request.fulfillment_order_id
        expect(client).to have_received(:create_fulfillment_order)
      end
    end
    
    context "#create_fulfillment_order" do
      context "when an error is returned by amazon" do
        let(:response){instance_double("Excon::Response", body: error_response)}
        before do
          allow(client).to receive(:create_fulfillment_order).and_raise(Excon::Errors::BadRequest.new("", "", response))
        end
        context "when a DeliverySLA not available error is returned" do
          let(:error_response){load_fixture("create_fulfillment_order_delivery_sla_error_response.xml")}
          it 'catches the error and raises a OnlyStandardServiceAvailableForDestination error' do
            expect{request.fulfillment_order_id}.to raise_error(OnlyStandardServiceAvailableForDestination)
          end
        end
        context "when a No inventory available error is returned" do
          let(:error_response){load_fixture("create_fulfillment_order_no_inventory_error_response.xml")}
          it 'catches the error and raises an InventoryNotAvailable error' do
            expect{request.fulfillment_order_id}.to raise_error(InventoryNotAvailable)
          end
        end
      end
    end
  end
end