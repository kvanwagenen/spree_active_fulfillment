module Spree::Fulfillment::Providers::Amazon
  module FbaUtils
    extend self
    
    def sku_from_seller_sku(seller_sku)
      /(FBA\.)?(?<sku>\S+)/.match(seller_sku)[:sku]
    end

    def seller_sku(sku)
      "FBA.#{sku}"
    end

    def parse_amazon_date(date_string)
      begin
        DateTime.strptime(date_string, "%Y-%m-%dT%H:%M:%S%z")
      rescue ArgumentError
        DateTime.strptime(date_string, "%Y-%m-%dT%H:%M:%S.%LZ")
      end
    end

    def amazon_address(spree_address)
      {
        'Name' => spree_address.full_name,
        'Line1' => spree_address.address1,
        'Line2' => spree_address.address2,
        'City' => spree_address.city,
        'StateOrProvinceCode' => spree_address.state.abbr,
        'CountryCode' => spree_address.country.iso || spree_address.country.iso_name,
        'PostalCode' => self.zip(spree_address),
        'PhoneNumber' => spree_address.phone
      }
    end

    def zip(addr)
      if addr.zipcode.length > 5
        addr.zipcode[0..4]
      else
        addr.zipcode
      end
    end

  end
end