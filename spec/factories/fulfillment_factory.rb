FactoryGirl.define do

  factory :fulfillment, class: Spree::Fulfillment do
    fulfiller_id 'an:id'
  end

end