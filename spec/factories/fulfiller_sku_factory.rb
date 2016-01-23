FactoryGirl.define do
  factory :fulfiller_sku, class: Spree::FulfillerSku do
    value { "FBA.#{::Faker::Product.model}" }
  end
end