require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FulfillmentInventorySupplyRequest do

    let(:client) do
      client = double("client")
      response = load_xml_fixture(File.join("fulfillment_inventory_supply_list_response.xml"))
      allow(client).to receive(:list_inventory_supply).and_return(response)
      client
    end
    
    let(:variants){[MockVariant.new("SampleSKU1"), MockVariant.new("SampleSKU2")]}

    let(:request) do
      MockVariant = Struct.new(:sku)
      request = FulfillmentInventorySupplyRequest.new(variants)
      allow(request).to receive(:client).and_return(client)
      request
    end
    
    context "#report" do
      it 'returns an instance of FulfillmentInventorySupply' do
        expect(request.report).to be_instance_of(FulfillmentInventorySupply)
      end
      
      context 'with variants having fulfiller skus' do
        let(:variants){create_list(:variant, 5)}
        let(:fulfiller_skus){["FSKU1", "FSKU2", "FSKU3"]}
        before do
          variants.first.fulfiller_skus.create(value: fulfiller_skus[0])
          variants.first.fulfiller_skus.create(value: fulfiller_skus[1])
          variants.second.fulfiller_skus.create(value: fulfiller_skus[2])
        end
        
        it 'includes fulfiller skus in the request' do
          expected_skus = variants.map{|v|[v.default_fulfiller_sku, v.fulfiller_skus.map(&:value)]}.flatten
          expect(client).to receive(:list_inventory_supply).with(hash_including(seller_skus: expected_skus))
          request.report
        end
      end
    end
  end
end