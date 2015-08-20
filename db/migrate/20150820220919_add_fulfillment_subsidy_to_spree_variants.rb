class AddFulfillmentSubsidyToSpreeVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :fulfillment_subsidy, :decimal
  end
end
