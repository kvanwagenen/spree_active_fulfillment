module Spree::Fulfillment::Providers::Amazon
  class FulfillmentSkuCountBuilder
  
    def initialize(shipment)
      @shipment = shipment
    end
    
    def fulfiller_sku_counts
      fulfiller_sku_counts = {}
      variants.each do |variant|
        add_fulfiller_sku_counts_for_variant(variant, fulfiller_sku_counts)
      end
      fulfiller_sku_counts
    end
    
    private
    
    attr_reader :shipment
    
    def add_fulfiller_sku_counts_for_variant(variant, fulfiller_sku_counts)
      required = sku_count_for_variant(variant)[:count]
      allocated = 0
      prioritized_variant_fulfiller_sku_levels(variant).each do |sku_level|
        to_allocate = [sku_level[:on_hand], required - allocated].min
        fulfiller_sku_counts[sku_level[:sku]] = to_allocate
        allocated += to_allocate
        break if allocated == required
      end
    end
    
    def sku_count_for_variant(variant)
      sku_counts.select{|sku_count|sku_count[:sku] == variant.sku}.try(:first)
    end
    
    def prioritized_variant_fulfiller_sku_levels(variant)
      variant_fulfiller_sku_levels(variant).sort{|a, b|a[:sku] <=> b[:sku]}
    end
    
    def variant_fulfiller_sku_levels(variant)
      fulfiller_sku_levels.select{|sku_level|variant.fulfiller_skus.map(&:value).include?(sku_level[:sku])}
    end
    
    def fulfiller_sku_levels
      @fulfiller_sku_levels ||= FulfillmentInventorySupplyRequest.new(variants).report.sku_levels
    end
    
    def variants
      @variants ||= Spree::Variant.includes(:fulfiller_skus).where(sku: skus)
    end
    
    def skus
      @skus ||= sku_counts.map{|sku_count|sku_count[:sku]}
    end
    
    def sku_counts
      @sku_counts ||= shipment.sku_counts
    end
  end
end