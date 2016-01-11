Spree::Variant.class_eval do
  has_many :fulfiller_skus
    
  after_create :create_default_fulfiller_sku
  
  def create_default_fulfiller_sku
    if !fulfiller_skus.where(value: default_fulfiller_sku).any?
      self.fulfiller_skus.create(value: default_fulfiller_sku)
    end
  end
  
  def default_fulfiller_sku
    "FBA.#{sku}"
  end
  
  def update_fulfiller_skus(fulfiller_skus)
    if fulfiller_skus
      fulfiller_skus = fulfiller_skus.select{|sku| sku != ""}
      to_keep = self.fulfiller_skus.where(value: fulfiller_skus)
      to_create = fulfiller_skus.select{|sku| !to_keep.map(&:value).include?(sku)}
      self.fulfiller_skus.where.not(value: fulfiller_skus).delete_all
      to_create.each do |sku|
        self.fulfiller_skus.create(value: sku) 
      end
    else
      self.fulfiller_skus.delete_all
    end
  end
end