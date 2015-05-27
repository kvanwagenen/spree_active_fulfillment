module Spree::Fulfillment::Providers::Amazon
  class Provider < Spree::Fulfillment::Provider

    def initialize
      @fulfillment_preview_cache = FulFillmentPreviewCache.new
    end
    
    def services
      [:standard, :expedited, :priority]
    end

    def can_fulfill?(package)
      raise NotImplementedError, "#can_fulfill? is not yet supported by #{self.class.name}."
    end

    def estimate_cost(package, service)
      fulfillment_preview(package, service).total_cost
    end

    def estimate_delivery_date(package, service)
      fulfillment_preview(package, service).delivery_date_estimate
    end

    def fulfill(shipment)
      raise NotImplementedError, "#fulfill is not yet supported by #{self.class.name}."
    end

    def cancel_fulfillment(fulfillment)
      raise NotImplementedError, "#cancel_fulfillment is not yet supported by #{self.class.name}."
    end

    private

    attr_accessor :fulfillment_preview_cache

    def fulfillment_preview(package, service)
      preview = fulfillment_preview_cache.get(package, service)
    end

  end
end