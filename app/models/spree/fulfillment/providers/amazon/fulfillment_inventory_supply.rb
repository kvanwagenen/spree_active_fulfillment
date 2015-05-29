module Spree::Fulfillment::Providers::Amazon
  class FulfillmentInventorySupply
  
    def initialize(parsed_xml)
      @xml = parsed_xml
    end

    def sku_levels
      @xml.css("InventorySupplyList member").map do |detail|
        sku_level_from_inventory_supply_detail(detail)
      end
    end

    private

    def sku_level_from_inventory_supply_detail(detail)
      {
        sku: FbaUtils.sku_from_seller_sku(detail.css("SellerSKU").text),
        on_hand: detail.css("InStockSupplyQuantity").text.to_i
      }
    end

  end
end