module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreviewRequest < PeddlerRequest

    def initialize(package, service)
      @package = package
      @service = service
    end

    def preview
      FulfillmentPreview.new(response_xml)
    end

    private

    attr_accessor :package, :service, :client

    def response_xml
      client.get_fulfillment_preview(address, items)
    end

    def client
      if !@client
        @client = MWS::FulfillmentOutboundShipment::Client.new(aws_merchant_credentials)
      end
      @client
    end

    def address(package)

    end

    def items(package)

    end

  end
end