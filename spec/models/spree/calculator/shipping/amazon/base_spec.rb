require 'spec_helper'

module Spree
describe Calculator::Shipping::Amazon::Base, type: :model do
  let(:calculator){Calculator::Shipping::Amazon::Expedited.new}
  let(:package){build(:stock_package_with_contents)}
  let(:cost_estimate){BigDecimal.new("14.5", 2)}
  let(:provider){instance_double(Fulfillment::Providers::Amazon::Provider, estimate_cost: cost_estimate)}
  before(:each) do
    allow(calculator).to receive(:provider).and_return(provider)
    
  end
  context '#compute_package' do
    context 'with fulfillment costs' do
      before(:each) do
        package.contents.map{|c|c.inventory_unit.variant}.each do |variant|
          allow(variant).to receive(:fulfillment_subsidy).and_return(1 + rand(2))
        end
      end

      it 'subtracts the sum of variant fulfillment costs from the value returned by the provider' do
        fulfillment_subsidy = package.contents.map{|content_item|content_item.inventory_unit.variant}.sum(&:fulfillment_subsidy)
        cost = cost_estimate - fulfillment_subsidy
        expect(calculator.compute_package(package)).to eq(cost)
      end
    end

    context 'without fulfillment costs' do
      it 'returns the provider\'s cost estimate' do
        expect(calculator.compute_package(package)).to eq(cost_estimate)
      end
    end
  end
end
end