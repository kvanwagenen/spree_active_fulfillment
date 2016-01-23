require 'spec_helper'
module Spree::Fulfillment::Providers::Amazon
klass = FulfillmentSkuCountBuilder
describe klass do
  context '#fulfiller_sku_counts' do
    let(:shipment) do
      create(
        :shipment_with_variants_with_fulfiller_skus, 
        variant_count: variants_per_shipment, 
        fulfiller_skus_per_variant: fulfiller_skus_per_variant, 
        line_items_quantity: units_required
      )
    end
    let(:builder) do
      klass.new(shipment)
    end
    let(:variants){Spree::Variant.includes(:fulfiller_skus).where(id: shipment.inventory_units.map(&:variant_id))}
    let(:fulfiller_skus){variants.map{|v|v.fulfiller_skus}.flatten.compact}
    let(:sku_levels) do
      levels = []
      levels_array_index = 0
      variants.each do |variant|
        variant_on_hand = 0
        variant.fulfiller_skus.each do |fulfiller_sku|
          sku_on_hand = levels_array[levels_array_index]
          variant_on_hand += sku_on_hand
          levels << {sku: fulfiller_sku.value, on_hand: sku_on_hand}
          levels_array_index += 1
        end
        variant.stock_items.each do |stock_item|
          stock_item.set_count_on_hand(variant_on_hand)
        end
      end
      levels
    end
    let(:report) {double(FulfillmentInventorySupply, sku_levels: sku_levels)}
    let(:inventory_request) {double(FulfillmentInventorySupplyRequest, report: report)}
    before(:each) do
      class_double(FulfillmentInventorySupplyRequest.name, new: inventory_request).as_stubbed_const
      sku_levels
    end
    let(:variants_per_shipment){1}
    let(:fulfiller_skus_per_variant){1}
    let(:units_required) {1}
    let(:levels_array) {[1]}
    let(:sku_counts){builder.fulfiller_sku_counts}
    context 'there is only one fulfiller_sku' do
      let(:fulfiller_skus_per_variant){1}
      it 'does not request inventory levels' do
        expect(report).not_to receive(:sku_levels)
        sku_counts
      end
    end
    context 'there is more than one fulfiller_sku on a variant' do
      let(:fulfiller_skus_per_variant){2}
      let(:levels_array) {[1,1]}
      it 'requests inventory levels' do
        expect(report).to receive(:sku_levels)
        sku_counts
      end
    end
    context 'first sku has enough' do
      it 'returns correct sku counts' do
        expect(sku_counts.size).to eq(1)
        expect(sku_counts[fulfiller_skus.first.value]).to eq(1)
      end
    end
    context 'first sku has more than enough' do
      let(:levels_array) {[3]}
      it 'returns correct sku counts' do
        expect(sku_counts.size).to eq(1)
        expect(sku_counts[fulfiller_skus.first.value]).to eq(1)
      end
    end
    context 'first sku has less than enough' do
      let(:units_required) {2}
      let(:fulfiller_skus_per_variant){2}
      let(:levels_array) {[1,1]}
      it 'returns correct sku counts' do
        expect(sku_counts.size).to eq(2)
        expect(sku_counts[fulfiller_skus.first.value]).to eq(1)
        expect(sku_counts[fulfiller_skus.second.value]).to eq(1)
      end
    end
    context 'first sku has none' do
      let(:units_required){2}
      let(:fulfiller_skus_per_variant){4}
      let(:levels_array){[0,1,0,1]}
      it 'returns correct sku counts' do
        expect(sku_counts.size).to eq(2)
        expect(sku_counts[fulfiller_skus.first.value]).to be_nil
        expect(sku_counts[fulfiller_skus.second.value]).to eq(1)
        expect(sku_counts[fulfiller_skus.third.value]).to be_nil
        expect(sku_counts[fulfiller_skus.fourth.value]).to eq(1)
      end
    end
    context 'a later sku has enough' do
      let(:units_required){3}
      let(:fulfiller_skus_per_variant){4}
      let(:levels_array){[0,2,4,0]}
      it 'returns correct sku counts' do
        expect(sku_counts.size).to eq(1)
        expect(sku_counts[fulfiller_skus.first.value]).to be_nil
        expect(sku_counts[fulfiller_skus.second.value]).to be_nil
        expect(sku_counts[fulfiller_skus.third.value]).to eq(3)
        expect(sku_counts[fulfiller_skus.fourth.value]).to be_nil
      end
    end
    context 'the total is less than the units_required' do
      let(:units_required){2}
      let(:fulfiller_skus_per_variant){2}
      let(:levels_array){[1,0]}
      it 'should raise an exception' do
        expect{sku_counts}.to raise_error(InventoryNotAvailable)
      end
    end
  end
end
end