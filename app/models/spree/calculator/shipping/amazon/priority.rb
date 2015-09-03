require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
  class Priority < Base

    def self.description
      "Amazon FBA Priority"
    end

    def service
      :priority
    end
    
    def guaranteed?
      true
    end

  end
end