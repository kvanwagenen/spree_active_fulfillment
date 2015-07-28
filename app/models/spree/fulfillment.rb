module Spree
  class Fulfillment < ActiveRecord::Base
    belongs_to :shipment

    serialize :fulfillment_data

    def cancel
      if cancellable?
        provider.cancel_fulfillment(self)
      end
    end

    def cancellable?
      raise NotImplementedError, "#cancellable? has not been implemented by #{self.class.name}"
    end

    protected

    def provider
      raise NotImplementedError, "#provider has not been implemented by #{self.class.name}"
    end

  end
end