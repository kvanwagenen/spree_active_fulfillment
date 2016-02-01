module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreviewRequest < PeddlerRequest

    def initialize(package, service, provider)
      @package = package
      @service = service
      @provider = provider
    end

    def preview
      FulfillmentPreview.new(parsed_response_xml)
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    attr_reader :package, :service, :provider

    def parsed_response_xml
      parsed_xml = client.get_fulfillment_preview(address, items)
      amazon_logger.debug("FulfillmentPreview Response: #{parsed_xml.to_xml}", package.order)
      parsed_xml
    end
    
    def amazon_logger
      @logger || AmazonLogger.new
    end

    def address
      FbaUtils.amazon_address(package.order.ship_address)     
    end

    def items
      fulfiller_sku_counts.keys.map do |sku|
        {
          'Quantity' => fulfiller_sku_counts[sku],
          'SellerSKU' => sku,
          'SellerFulfillmentOrderItemId' => "#{package.order.id}:#{sku}"
        }
      end
    end
    
    def fulfiller_sku_counts
      @fulfiller_sku_counts ||= FulfillmentSkuCountBuilder.new(package.to_shipment, provider).fulfiller_sku_counts
    end

  end
end