Spree::StockItem.class_eval do
  def self.find_by_variant_sku(sku)
    join(:variant).where("spree_variants.sku = ?", sku).take
  end
end