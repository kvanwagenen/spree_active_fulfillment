module Spree::Fulfillment::Providers::Amazon
  class VariantCostCalculator
    
    def fulfillment_cost(variant)
      dims = [variant.width, variant.height, variant.depth]
      dims = dims.map{|d|(d && d >= 0) ? d : 1}.sort
      if dims[0] > 7.5 || dims[1] > 13.5 || dims[2] > 17.5 || (variant.weight / 16.0) > 19.5
        total_cost(:oversize)
      else
        total_cost(:standard)
      end
    end
    
    private
    
    @@size_costs = {
      standard: {
        unit: 0.75,
        order: 4.75
      },
      oversize: {
        unit: 3.0,
        order: 7
      }
    }
    
    mattr_reader :size_costs
    
    def total_cost(size)
      size_costs[size][:unit] + size_costs[size][:order]
    end
    
  end
end