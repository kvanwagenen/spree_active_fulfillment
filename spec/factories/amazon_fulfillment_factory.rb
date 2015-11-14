FactoryGirl.define do

  factory :amazon_fulfillment, class: Spree::Fulfillment::Providers::Amazon::AmazonFulfillment do
    fulfiller_id 'an:id'
    
    factory :cancellable_amazon_fulfillment do
      status "planning"
    end
    
    factory :uncancellable_amazon_fulfillment do
      status "processing"
    end
  end

end