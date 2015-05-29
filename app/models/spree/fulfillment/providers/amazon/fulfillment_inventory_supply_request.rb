module Spree::Fulfillment::Providers::Amazon
  class FulfillmentInventorySupplyRequest < PeddlerRequest

    def initialize(variants)
      @variants = variants
    end
    
    def report
      FulfillmentInventorySupply.new(parsed_response)
    end

    protected

    def client_class
      ::MWS::FulfillmentInventory::Client
    end

    private

    attr_reader :variants

    def parsed_response
      client.list_inventory_supply(seller_skus: skus)
    end

    def skus
      variants.map{|v|FbaUtils.seller_sku(v.sku)}
    end
  end
end