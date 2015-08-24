require 'spec_helper'

module Spree
describe Fulfillment::Providers::Amazon::VariantCostCalculator do
  
  let(:calculator){Fulfillment::Providers::Amazon::VariantCostCalculator.new}
  let(:oversize_cost){10}
  let(:cost){calculator.fulfillment_cost(variant)}
  context 'with standard sized variant' do
    let(:variant){build(:variant, depth: 5, width: 5, height: 5, weight: 10)}
    it 'returns standard cost' do
      expect(cost).to eq(5.50)  
    end
  end
  context 'with variant with longest side over 17 inches' do
    let(:variant){build(:variant, depth: 18, width: 5, height: 5, weight: 10)}
    it 'returns oversize cost' do
      expect(cost).to eq(oversize_cost)  
    end
  end
  context 'with variant with median side over 14 inches' do
    let(:variant){build(:variant, depth: 15, width: 14.5, height: 5, weight: 10)}
    it 'returns oversize cost' do
      expect(cost).to eq(oversize_cost)
    end
  end
  context 'with variant with shortest side over 8 inches' do
    let(:variant){build(:variant, depth: 10, width: 9.5, height: 9, weight: 10)}
    it 'returns oversize cost' do
      expect(cost).to eq(oversize_cost)
    end
  end
  context 'with variant with weight over 20 lbs' do
    let(:variant){build(:variant, depth: 5, width: 5, height: 5, weight: 20.5 * 16)}
    it 'returns oversize cost' do
      expect(cost).to eq(oversize_cost)
    end
  end
  
end
end