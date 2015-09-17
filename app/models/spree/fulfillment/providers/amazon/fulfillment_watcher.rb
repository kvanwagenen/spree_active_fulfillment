module Spree::Fulfillment::Providers::Amazon
  class FulfillmentWatcher

    def refresh_fulfillments
      logger.info "Begin refreshing Amazon fulfillments..."
      start = Time.now
      fulfillments_needing_refresh.each do |fulfillment|
        begin
          fulfillment.refresh
        rescue Exception => e
          logger.error("RefreshFulfillment Error! Order:#{fulfillment.shipment.order.number} Shipment:#{fulfillment.shipment.number}")
          logger.error("#{e}\n#{e.backtrace}")
        end
        sleep(0.5)
      end
      logger.info "Refreshed #{fulfillments_needing_refresh.length} fulfillments in #{Time.now - start} seconds"
    end

    private

    def fulfillments_needing_refresh
      @fulfillments_needing_refresh ||= AmazonFulfillment.refreshable
    end

    def logger
      Rails.logger
    end

  end
end