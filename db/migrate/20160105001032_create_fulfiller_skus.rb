class CreateFulfillerSkus < ActiveRecord::Migration
  def change
    create_table :spree_fulfiller_skus do |t|
      t.integer :variant_id, index: true
      t.string :value
    end
  end
end
