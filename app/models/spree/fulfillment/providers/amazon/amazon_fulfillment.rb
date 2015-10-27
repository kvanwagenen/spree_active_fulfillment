module Spree::Fulfillment::Providers::Amazon
  class AmazonFulfillment < Spree::Fulfillment
    scope :refreshable, -> { joins(:shipment).where("spree_fulfillments.status in ('received','planning','processing') OR (spree_fulfillments.status = 'complete' AND spree_shipments.state in ('pending', 'ready'))") }    

    def handle_status
      case status
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

    def processing
      if fulfillment_data && fulfillment_data[:shipments] && fulfillment_data[:shipments].select{ |shipment| shipment[:status] == "shipped"}.any?
        capture_payments
        ship_shipment
      end
    end

    def capture_payments
      shipment.order.payments.each do |payment|
        payment.capture! if !["invalid", "failed", "completed", "void"].include?(payment.state)
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
      capture_payments
      ship_shipment
      notify_customer_service
      # TODO Probably send an email to customer service so they can contact the customer
    end
    
    def notify_customer_service
      
    end
  end
end