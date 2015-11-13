FactoryGirl.define do

  factory :amazon_fulfillment, class: Spree::Fulfillment::Providers::Amazon::AmazonFulfillment do
    fulfiller_id 'an:id'
  end

end