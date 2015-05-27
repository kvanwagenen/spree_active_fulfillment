require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
  class Priority < Base

    def description
      "Amazon FBA Priority"
    end

    def service
      :priority
    end

  end
end