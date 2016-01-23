require 'spec_helper'
module Spree::Fulfillment::Providers::Amazon
klass = FulfillmentSkuCountBuilder
describe klass do
  context '#fulfiller_sku_counts' do
    let(:shipment) {create(:shipment_with_variants_with_fulfiller_skus, variant_count: variants_per_shipment, fulfiller_skus_per_variant: fulfiller_skus_per_variant)}
    let(:builder) do
      klass.new(shipment)
    end
    let(:variants){Spree::Variant.includes(:fulfiller_skus).where(id: shipment.inventory_units.map(&:variant_id))}
    let(:fulfiller_skus){variants.map{|v|v.fulfiller_skus}.flatten.compact}
    let(:sku_levels) do
      levels = {}
      levels_array_index = 0
      variants.each do |variant|
        variant.fulfiller_skus.each do |fulfiller_sku|
          levels[fulfiller_sku.value] = levels_array[levels_array_index]
          levels_array_index += 1
        end
      end
      levels
    end
    let(:report) {double(FulfillmentInventorySupply, sku_levels: sku_levels)}
    let(:inventory_request) {double(FulfillmentInventorySupplyRequest, report: report)}
    before(:each) do
      class_double(FulfillmentInventorySupplyRequest.name, new: inventory_request).as_stubbed_const
    end
    let(:variants_per_shipment){1}
    let(:fulfiller_skus_per_variant){1}
    context 'first sku has enough' do
      let(:required) {1}
      let(:levels_array) {[1]}
      it 'returns correct sku counts' do
        binding.pry
        sku_counts = builder.fulfiller_sku_counts
        expect(sku_counts.size).to eq(1)
        expect(sku_counts[fulfiller_skus.first.value]).to eq(1)
      end
    end
    context 'first sku has more than enough' do
      
    end
    context 'first sku has less than enough' do
      
    end
    context 'the total is less than the required' do
      
    end
  end
end
end