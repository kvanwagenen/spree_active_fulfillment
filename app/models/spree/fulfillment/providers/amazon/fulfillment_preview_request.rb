module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreviewRequest < PeddlerRequest

    def initialize(package, service)
      @package = package
      @service = service
    end

    def preview
      FulfillmentPreview.new(parsed_response_xml)
    end

    protected

    def client_class
      ::MWS::FulfillmentOutboundShipment::Client
    end

    private

    attr_reader :package, :service

    def parsed_response_xml
      client.get_fulfillment_preview(address, items)
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
          'SellerSKU' => FbaUtils.seller_sku(sku_count.sku),
          'SellerFulfillmentOrderItemId' => "#{package.order.id}:#{sku_count.sku}"
        }
      end
    end

  end
end