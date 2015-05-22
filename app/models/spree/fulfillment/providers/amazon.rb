module Spree
  module Fulfillment::Providers
    class Amazon < Spree::Fulfillment::Provider

      def initialize
        @fulfillment_preview_cache = FulFillmentPreviewCache.new
      end
      
      def services
        [:standard, :expedited, :priority]
      end

      def estimate_cost(package, service)
        fulfillment_preview(package, service).cost
      end

      def estimate_delivery_date(package, ship_date, service)
        fulfillment_preview(package, service).delivery_date_estimate
      end

      def fulfill(shipment)
        raise NotImplementedError, "#fulfill is not supported by #{self.class.name}."
      end

      private

      attr_accessor :fulfillment_preview_cache

      def fulfillment_preview(package, service)
        preview = fulfillment_preview_cache.get(package, service)
      end

    end
  end
end