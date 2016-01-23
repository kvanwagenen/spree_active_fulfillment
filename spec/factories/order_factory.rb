FactoryGirl.define do
  factory :order_with_line_items_quantity, parent: :order do
    transient do
      line_items_quantity 1
      line_items_count 1
    end
    after(:create) do |order, evaluator|
      create_list(:line_item, evaluator.line_items_count, order: order, price: evaluator.line_items_price, quantity: evaluator.line_items_quantity)
      order.line_items.reload # to ensure order.line_items is accessible after
    end
  end
end