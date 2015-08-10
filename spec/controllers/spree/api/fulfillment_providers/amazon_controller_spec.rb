require 'spec_helper'

module Spree::Api::Fulfillment
  describe AmazonController, type: :controller do

    let(:amazon_provider) do
      amazon_provider = double()
      allow(amazon_provider).to receive(:update_inventory_levels)
      amazon_provider
    end

    let(:variants) {create_list(:master_variant, 2)}

    before do
      stub_authentication!
      allow(Spree::FulfillmentConfig).to receive(:amazon_provider).and_return(amazon_provider)
    end

    context "#update_inventory" do
      let!(:current_api_user) do
        user = double(Spree.user_class)
        allow(user).to receive_message_chain(:spree_roles, :pluck).and_return(["admin"])
        allow(user).to receive(:has_spree_role?).with("admin").and_return(true)
        user
      end

      let(:params) { {skus: variants.map(&:sku)} }

      it 'sends update_inventory_levels with the variants that have the given skus to the amazon provider' do
        put :update_inventory, params 
        expect(amazon_provider).to have_received(:update_inventory_levels).with(variants)
      end

    end
  end
end