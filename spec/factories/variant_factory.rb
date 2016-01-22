FactoryGirl.define do
  factory :variant_with_fulfiller_skus, parent: :master_variant do
    transient do
      sku_count 3
    end
    after(:create) do |variant, evaluator|
      create_list(:fulfiller_sku, evaluator.sku_count, variant: variant)
    end
  end
end