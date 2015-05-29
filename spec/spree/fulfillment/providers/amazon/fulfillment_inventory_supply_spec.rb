require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FulfillmentInventorySupply do
      
    let(:supply) do
      xml = load_xml_fixture(File.join("reports", "fulfillment_inventory_supply_list_response.xml"))
      supply = FulfillmentInventorySupply.new(xml)
      supply
    end

    context "#sku_levels" do

      it 'correctly parses the sku levels from the response' do
        sku_levels = supply.sku_levels
        expect(sku_levels.length).to eq(2)
        expect(sku_levels[0][:sku]).to eq("SampleSKU1")
        expect(sku_levels[0][:on_hand]).to eq(15) 
      end

    end
  end
end