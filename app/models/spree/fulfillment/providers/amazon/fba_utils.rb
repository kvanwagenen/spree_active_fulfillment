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
      DateTime.strptime(date_string, "%Y-%m-%dT%H:%M:%SZ")
    end

  end
end