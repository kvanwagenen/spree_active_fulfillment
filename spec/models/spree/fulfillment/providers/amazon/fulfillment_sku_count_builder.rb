require 'spec_helper'
module Spree::Fulfillment::Providers::Amazon
klass = FulfillmentSkuCountBuilder
describe klass do
  context '#fulfiller_sku_counts' do
    let(:shipment) {create(:shipment_with_fulfiller_skus)}
    let(:builder) do
      klass.new(shipment)
    end
    let(:sku_levels) do
      levels = {}
      variants = Spree::Variant.includes(:fulfiller_skus).where(id: shipment.inventory_units.map(&:variant_id))
      variants.each do |variant|
        variant.fulfiller_skus.each do |fulfiller_sku|
          levels[variant]  
        end
      end
      fulfiller_skus
    end
    let(:report) {double(FulfillmentInventorySupply, sku_levels: sku_levels)}
    before do
      class_double('FulfillmentInventorySupplyRequest', report: report).as_stubbed_const
    end
    it 'returns correct sku counts' do
      
    end
  end
end
end