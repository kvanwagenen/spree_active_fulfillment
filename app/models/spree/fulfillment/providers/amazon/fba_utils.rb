module Spree::Fulfillment::Providers::Amazon
  module FbaUtils
    extend self
    
    def sku_from_seller_sku(seller_sku)
      /(fba\.)?(?<sku>\w+)/.match(seller_sku)[:sku]
    end

    def seller_sku(sku)
      "fba.#{sku}"
    end

  end
end