FactoryGirl.define do
  factory :shipment_with_variants_with_fulfiller_skus, class: Spree::Shipment do
    tracking 'U10000'
    cost 100.00
    state 'pending'
    stock_location
    
    transient do
      fulfiller_skus_per_variant 1
      variant_count 1
      line_items_quantity 1
    end
    
    after(:create) do |shipment, evaluator|
      shipment.order = create(:order_with_line_items_quantity, line_items_count: evaluator.variant_count, line_items_quantity: evaluator.line_items_quantity)
      shipment.add_shipping_method(create(:shipping_method), true)
      shipment.order.line_items.each do |line_item|
        line_item.variant = create(:variant_with_fulfiller_skus, sku_count: evaluator.fulfiller_skus_per_variant)
        line_item.quantity.times do
          shipment.inventory_units.create(
            order_id: shipment.order_id,
            variant_id: line_item.variant_id,
            line_item_id: line_item.id
          )
        end
      end
    end
  end
end