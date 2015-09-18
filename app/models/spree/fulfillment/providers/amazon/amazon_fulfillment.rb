module Spree::Fulfillment::Providers::Amazon
  class AmazonFulfillment < Spree::Fulfillment
    scope :refreshable, -> { where(status: ["received","planning","processing"]) }    

    def status=(new_status)
      if new_status && (status != new_status || ["processing", "complete"].include?(new_status))
        handle_status_change(new_status)
      end
      super(new_status)
    end

    def refresh
      provider.refresh_fulfillment(self)
    end

    def cancellable?
      ["received", "planning"].include?(status)
    end
    
    def tracking_numbers
      @tracking_numbers ||= packages.map{|package| package[:tracking_number]}.compact.join(", ")
    end
    
    def sync_tracking_numbers
      if tracking_numbers
        shipment.tracking = tracking_numbers
        shipment.save
      end
    end

    protected

    def provider 
      Spree::FulfillmentConfig.amazon_provider
    end

    private

    def handle_status_change(final_status)
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
      if fulfillment_data[:shipments].select{ |shipment| shipment[:status] == "shipped"}.any?
        capture_payments
        ship_shipment
      end
    end

    def capture_payments
      shipment.order.payments.each do |payment|
        payment.capture! if !["invalid", "failed", "completed"].include?(payment.state)
      end
    end

    def ship_shipment
      if shipment
        sync_tracking_numbers
        if shipment.state != "shipped"
          shipment.ready
          shipment.ship
        end
      end
    end

    def packages
      fulfillment_data[:shipments].map{|shipment| shipment[:packages]}.flatten.compact
    end

    def cannot_fulfill
      if !shipment.order.canceled?
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