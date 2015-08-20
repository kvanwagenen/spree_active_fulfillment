require_dependency 'spree/calculator'

module Spree::Calculator::Shipping::Amazon
	class Base < Spree::ShippingCalculator
		
    def compute_package(package)
      adjusted_cost(package)
    end

    def estimate_delivery_window(package, ship_date)
      provider.estimate_delivery_window(package, service, ship_date)
    end

    def available?(package)
      provider.can_fulfill?(package)
    end

    def fulfillment_provider
      provider
    end

    def service
      raise NotImplementedError, "Please implement 'service' in your calculator: #{self.class.name}"
    end

    def rate_daily_expiration_hour
      if respond_to?(:preferred_rate_daily_expiration_hour) && preferred_rate_daily_expiration_hour
        preferred_rate_daily_expiration_hour
      else
        11
      end
    end

    protected

    def self.description
      raise NotImplementedError, "Please implement 'description' in your calculator: #{self.class.name}"
    end    

    private

    def provider
      Spree::FulfillmentConfig.amazon_provider
    end

    def adjusted_cost(package)
      provider_cost(package) - variant_fulfillment_subsidy_total(package)
    end

    def provider_cost(package)
      provider.estimate_cost(package, service)
    end

    def variant_fulfillment_subsidy_total(package)
      if Spree::Variant.new.respond_to?(:fulfillment_subsidy)
        package.contents.map{|content_item|content_item.inventory_unit.variant}.inject(0) do |sum, variant|
          variant.fulfillment_subsidy ? sum + variant.fulfillment_subsidy : sum
        end
      else
        0
      end
    end

	end
end