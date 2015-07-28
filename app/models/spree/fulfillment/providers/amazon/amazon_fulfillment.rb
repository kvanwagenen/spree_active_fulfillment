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

    protected

    def provider
      Spree::Fulfillment::Config.amazon_provider
    end

    private

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
      if fulfillment_data[:shipments].select{ |shipment| shipment[:status] != "shipped"}.empty?
        capture_payments
        ship_shipment
      end
    end

    def capture_payments
      shipment.order.payments.each(&:capture!)
    end

    def ship_shipment
      if(shipment && shipment.state != "shipped")
        shipment.ready
        shipment.ship
        if tracking_number
          shipment.tracking = tracking_number
          shipment.save
        end
      end
    end

    def tracking_number
      @tracking_number ||= packages.map{|package| package[:tracking_number]}.compact[0]
    end

    def packages
      fulfillment_data[:shipments].map{|shipment| shipment[:packages]}.flatten.compact
    end

    def cannot_fulfill
      if shipment.order.state != "cancelled"
        shipment.order.cancel
      end
    end

    def complete
      capture_payments
      ship_shipment
    end    

    def complete_partialled
      # TODO Probably send an email to customer service so they can contact the customer
    end

  end
end