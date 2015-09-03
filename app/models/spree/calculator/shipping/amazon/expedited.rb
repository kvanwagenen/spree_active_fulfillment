require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
  class Expedited < Base

    def self.description
      "Amazon FBA Expedited"
    end

    def service
      :expedited
    end
    
    def guaranteed?
      true
    end

  end
end