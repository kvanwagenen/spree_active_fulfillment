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

    def sellable_rows
      csv.select{|row|row['Warehouse-Condition-code'] == 'SELLABLE'}
    end

    def built_sku_levels
      sellable_rows.map do |row|
        sku_level(row)
      end
    end

    def sku_level(row)
      {
        sku: row['seller-sku'],
        on_hand: row['Quantity Available'].to_i
      }
    end

  end
end