module Spree
  class Fulfillment < ActiveRecord::Base
    belongs_to :shipment

    serialize :fulfillment_data

    protected

    def cancel
      if cancellable?
        provider.cancel_fulfillment(self)
      end
    end
  end
end