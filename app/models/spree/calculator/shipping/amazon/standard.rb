require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
  class Standard < Base

    def description
      "Amazon FBA Standard"
    end

    def service
      :standard
    end

  end
end