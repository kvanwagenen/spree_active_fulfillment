module Spree::Fulfillment::Providers::Amazon
  class FulfillmentSkuCountBuilder
  
    def initialize(shipment)
      @shipment = shipment
    end
    
    def fulfiller_sku_counts
      counts = {}
      variants.each do |variant|
        add_fulfiller_sku_counts_for_variant(variant, counts)
      end
      counts
    end
    
    private
    
    attr_reader :shipment
    
    def add_fulfiller_sku_counts_for_variant(variant, fulfiller_sku_counts)
      required = sku_count_for_variant(variant)[:count]
      allocated = 0
      prioritized_variant_fulfiller_sku_levels(variant).each do |sku_level|
        allocating = [sku_level[:on_hand], required - allocated].min
        fulfiller_sku_counts[sku_level[:sku]] = allocating if allocating > 0
        allocated += allocating
        break if allocated == required
      end
      if allocated < required
        logger.warn("Fulfillment Warning: InventoryNotAvailable Order: #{shipment.order.number}, Variant: #{variant.sku}")
        raise InventoryNotAvailable
      end
    end
    
    def sku_count_for_variant(variant)
      sku_counts.select{|sku_count|sku_count[:sku] == variant.sku}.try(:first)
    end
    
    def prioritized_variant_fulfiller_sku_levels(variant)
      variant_fulfiller_sku_levels(variant).sort_by{|sku_level|[-sku_level[:on_hand], sku_level[:sku]]}
    end
    
    def variant_fulfiller_sku_levels(variant)
      fulfiller_sku_levels.select{|sku_level|variant.fulfiller_skus.map(&:value).include?(sku_level[:sku])}
    end
    
    def fulfiller_sku_levels
      @fulfiller_sku_levels ||= begin
        if variants.select{|v|v.fulfiller_skus.length > 1}.any?
          FulfillmentInventorySupplyRequest.new(variants).report.sku_levels
        else
          variants.map do |v|
            v.fulfiller_skus.map do |fulfiller_sku|
              {
                sku: fulfiller_sku.value,
                on_hand: v.stock_items.select{|s|s.stock_location_id == stock_location.id}.first.count_on_hand
              }
            end
          end.flatten
        end
      end
    end
    
    def variants
      @variants ||= Spree::Variant.includes(:fulfiller_skus, :stock_items).where(sku: skus).where("spree_stock_items.stock_location_id = ?", stock_location.id).references(:stock_items)
    end
    
    def skus
      @skus ||= sku_counts.map{|sku_count|sku_count[:sku]}
    end
    
    def sku_counts
      @sku_counts ||= shipment.sku_counts
    end
    
    def stock_location
      shipment.stock_location
    end
    
    def logger
      Rails.logger
    end
  end
end