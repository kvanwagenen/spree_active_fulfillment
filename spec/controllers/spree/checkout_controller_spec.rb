require 'spec_helper'

describe Spree::CheckoutController, type: :controller do
  render_views
  
  # Copied from spree frontend controller tests
  let(:token) { 'some_token' }
  let(:user) { Spree::LegacyUser.new }

  let(:address_params) do
    address = FactoryGirl.build(:address)
    address.attributes.except("created_at", "updated_at")
  end

  before do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages spree_current_user: user
    allow(controller).to receive_messages current_order: order
  end
  # End copy
  
  let(:order){create(:order_with_line_items)}
  context '#update' do
    let(:params){{id: order.to_param, state: "confirm"}}
    let(:response){spree_put(:update, params)}
    context 'with an order at the confirm state' do
      before do
        order.state = "confirm"
        order.save
        allow(order).to receive(:payment_required?).and_return(false)
      end
      context 'when an InventoryNotAvailable error is raised' do
        before do
          allow(order).to receive(:fulfilled_shipments).and_raise(Spree::Fulfillment::Providers::Amazon::InventoryNotAvailable)
          allow(Spree::FulfillmentConfig.amazon_provider).to receive(:update_inventory_levels)
        end
        it 'requests an inventory update for each variant in the order' do
          variants = order.line_items.map(&:variant)
          expect(Spree::FulfillmentConfig.amazon_provider).to receive(:update_inventory_levels).with(variants)
          response
        end
        it 'redirects to the cart' do
          expect(response).to redirect_to spree.cart_path
        end
        it 'informs the customer with a flash message' do
          response
          expect(flash[:error]).to eq(Spree.t(:insufficient_inventory_exists_to_fulfill_your_order))
        end
      end
      
      context 'when an OnlyStandardServiceAvailableForDestination error is raised' do
        before do
          allow(Spree::FulfillmentConfig.amazon_provider).to receive(:fulfill).and_raise(Spree::Fulfillment::Providers::Amazon::OnlyStandardServiceAvailableForDestination)
          allow(order.shipments.first).to receive(:fulfillment_provider).and_return(Spree::FulfillmentConfig.amazon_provider)
          order.shipments.first.shipping_rates.first.shipping_method.calculator = Spree::Calculator::Shipping::Amazon::Priority.new
        end
        it 'removes the non-standard shipping rates from the shipment' do
          response
          order.reload
          order.fulfilled_shipments.each do |shipment|
            expect(shipment.shipping_rates.select{|rate|rate.shipping_method.calculator.service != :standard}.empty?).to be_truthy
          end
        end
        it 'redirects to the delivery page' do
          expect(response).to redirect_to spree.checkout_state_path(:delivery)
        end
        it 'informs the customer with a flash message' do
          response
          expect(flash[:error]).to eq(Spree.t(:only_standard_shipping_available_to_destination))
        end
      end
    end
  end
  
end