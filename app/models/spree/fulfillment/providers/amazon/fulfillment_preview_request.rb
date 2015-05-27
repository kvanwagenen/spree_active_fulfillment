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
      @client ||= ::MWS::FulfillmentOutboundShipment::Client.new(aws_merchant_credentials)
    end

    def address
      ship_address = package.order.ship_address
      {
        'Name' => ship_address.full_name,
        'Line1' => ship_address.address1,
        'Line2' => ship_address.address2,
        'City' => ship_address.city,
        'StateOrProvinceCode' => ship_address.state.to_s,
        'CountryCode' => ship_address.state.country.iso,
        'PostalCode' => ship_address.zipcode,
        'PhoneNumber' => ship_address.phone
      }
    end

    def items
      package.sku_counts.map do |sku_count|
        {
          'Quantity' => sku_count.count,
          'SellerSKU' => "fba.#{sku_count.sku}",
          'SellerFulfillmentOrderItemId' => "#{package.order.id}:#{sku_count.sku}"
        }
      end
    end

  end
end