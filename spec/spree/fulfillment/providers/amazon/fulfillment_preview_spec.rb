require 'spec_helper'

describe Spree::Fulfillment::Providers::Amazon::FulfillmentPreview do
  let(:preview){ build(:fulfillment_preview) } 

  before :each do
    klass = Spree::Fulfillment::Providers::Amazon::FulfillmentPreview
    klass.send(:public, *klass.private_instance_methods)
  end

  context "#total_cost" do
    it 'should return the cost for the given service' do
      expect(preview.total_cost(:standard)).to eq(1675)
      expect(preview.total_cost(:expedited)).to eq(1360)
    end
  end

  context "#delivery_date_estimate" do
    it 'should return valid delivery date estimates for the given service' do
      expect(preview.delivery_date_estimate(:expedited).earliest).to eq(DateTime.new(2014,1,5,7,0,0))
      expect(preview.delivery_date_estimate(:expedited).latest).to eq(DateTime.new(2014,1,6,6,59,59))
    end
  end

end