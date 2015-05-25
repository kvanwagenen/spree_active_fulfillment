require_dependency 'spree/calculator'

module Spree::Calculator::Shipping
	module Amazon
		class Base < Spree::ShippingCalculator
			
      def compute_package(package)

      end

      def compute_shipment(shipment)

      end

      def available?(package)
        provider.can_fulfill?(package)
      end

      protected

      def description
        raise NotImplementedError, "Please implement 'description' in your calculator: #{self.class.name}"
      end

      def shipping_speed_category
        raise NotImplementedError, "Please implement 'shipping_speed_category' in your calculator: #{self.class.name}"
      end

      private

      def provider
        Spree::Fulfillment::Config.amazon_provider
      end

		end
	end
end