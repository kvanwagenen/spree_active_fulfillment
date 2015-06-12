module Spree::Fulfillment::Providers::Amazon
  class AmazonFulfillment < Spree::Fulfillment
    scope :refreshable, -> { where(status: ["received","planning","processing"]) }    

    def status=(new_status)
      if status != new_status && !status.nil? 
        handle_status_change(new_status, status)
      end
      super(new_status)
    end

    def refresh
      provider.refresh_fulfillment(self)
    end

    def cancellable?
      ["received", "planning"].include?(status)
    end

    private

    def provider
      Spree::Fulfillment::Config.amazon_provider
    end

    def handle_status_change(final_status, initial_status)
      case final_status
      when "processing"
        processing
      when "invalid", "unfulfillable"
        cannot_fulfill
      when "complete"
        complete
      when "complete_partialled"
        complete_partialled
      end
    end

    def processing
      ship_shipment
    end

    def ship_shipment
      if(shipment.state != "shipped")
        shipment.ship
      end
    end

    def cannot_fulfill
      if shipment.order.state != "cancelled"
        shipment.order.cancel
      end
    end

    def complete
      ship_shipment
    end    

    def complete_partialled
      # TODO Probably send an email to customer service so they can contact the customer
    end

  end
end