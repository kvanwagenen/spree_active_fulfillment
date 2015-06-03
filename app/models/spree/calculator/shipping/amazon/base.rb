require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
	class Base < Spree::ShippingCalculator
		
    def compute_package(package)
      provider.estimate_cost(package, service)
    end

    def available?(package)
      provider.can_fulfill?(package)
    end

    protected

    def self.description
      raise NotImplementedError, "Please implement 'description' in your calculator: #{self.class.name}"
    end

    def service
      raise NotImplementedError, "Please implement 'service' in your calculator: #{self.class.name}"
    end

    private

    def provider
      Spree::Fulfillment::Config.amazon_provider
    end

	end
end