class AddDefaultFulfillerSkus < ActiveRecord::Migration
  def change
    Spree::Variant.find_each(batch_size: 1000) do |variant|
      variant.create_default_fulfiller_sku
    end
  end
end
