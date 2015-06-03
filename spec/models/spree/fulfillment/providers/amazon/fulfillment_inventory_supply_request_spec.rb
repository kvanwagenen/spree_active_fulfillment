require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FulfillmentInventorySupplyRequest do

    let(:client) do
      client = double("client")
      response = load_xml_fixture(File.join("reports", "fulfillment_inventory_supply_list_response.xml"))
      allow(client).to receive(:list_inventory_supply).and_return(response)
      client
    end

    let(:request) do
      MockVariant = Struct.new(:sku)
      variants = [MockVariant.new("SampleSKU1"), MockVariant.new("SampleSKU2")]
      request = FulfillmentInventorySupplyRequest.new(variants)
      allow(request).to receive(:client).and_return(client)
      request
    end

    context "#report" do
      it 'returns an instance of FulfillmentInventorySupply' do
        expect(request.report).to be_instance_of(FulfillmentInventorySupply)
      end
    end

  end
end