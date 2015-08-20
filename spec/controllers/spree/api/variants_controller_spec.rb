require 'spec_helper'

module Spree
describe Api::VariantsController, type: :controller do
  render_views

  let(:variants){create_list(:master_variant, 2)}
  before(:each) do
    stub_authentication!
    variants.each do |v|
      v.fulfillment_subsidy = 1+rand(2)
      v.save
    end
  end
  
  context 'as an admin' do
    # sign_in_as_admin!
    let!(:current_api_user) do
      user = double(Spree.user_class)
      allow(user).to receive_message_chain(:spree_roles, :pluck).and_return(["admin"])
      allow(user).to receive(:has_spree_role?).with("admin").and_return(true)
      user
    end
    
    context '#show' do
      it 'includes fulfillment_subsidy in the view' do
        api_get :show, {id: variants[0].to_param}
        expect(json_response[:fulfillment_subsidy]).to eq(variants[0].fulfillment_subsidy.to_s)
      end
    end
  end
end
end