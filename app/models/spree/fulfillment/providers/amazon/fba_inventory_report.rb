module Spree::Fulfillment::Providers::Amazon
  class FbaInventoryReport

    def initialize(parsed_csv)
      @csv = parsed_csv
    end

    def sku_levels
      @sku_levels ||= built_sku_levels
    end

    private

    attr_reader :csv

    def built_sku_levels
      csv.each do |row|
        next if row['Warehouse-Condition-code'] != 'SELLABLE'
        sku_level(row)
      end
    end

    def sku_level(row)
      {
        sku: FbaUtils.sku_from_seller_sku(row['seller-sku']),
        on_hand: row['Quantity Available'].to_i
      }
    end

  end
end