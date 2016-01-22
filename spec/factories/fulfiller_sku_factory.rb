FactoryGirl.define do
  factory :fulfiller_sku, class: Spree::FulfillerSku do
    value { "FBA.#{::Faker::Product.model}" }
    on_hand { rand(3) }
  end
end