FactoryGirl.define do
  factory :stock_package_with_contents, parent: :stock_package do
    transient do
      variants_contents { { build(:variant) => 1, build(:variant) => 3 } }
    end
  end
end 