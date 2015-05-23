module Spree
  module Fulfillment
    class Provider

      def services
        raise NotImplementedError, "#services is not supported by #{self.class.name}."
      end

      def estimate_cost(package, service)
        raise NotImplementedError, "#package_estimate is not supported by #{self.class.name}."
      end

      def estimate_delivery_date(package, service, ship_date)
        raise NotImplementedError, "#estimate_delivery_date is not supported by #{self.class.name}."
      end

      def fulfill(shipment)
        raise NotImplementedError, "#fulfill is not supported by #{self.class.name}."
      end

    end
  end
end