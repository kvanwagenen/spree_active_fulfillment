require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
  class Expedited < Base

    def description
      "Amazon FBA Expedited"
    end

    def service
      :expedited
    end

  end
end