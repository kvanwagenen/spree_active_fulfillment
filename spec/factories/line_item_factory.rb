FactoryGirl.define do
  factory :line_item_with_quantity, class: Spree::LineItem do
    quantity 1
    price { BigDecimal.new('10.00') }
    pre_tax_amount { price }
    order
    transient do
      association :product
    end
    variant{ product.master }
  end
end
