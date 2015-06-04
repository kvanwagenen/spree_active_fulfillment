FactoryGirl.define do
	factory :standard_fulfillment_preview_request, class: Spree::Fulfillment::Providers::Amazon::FulfillmentPreviewRequest do
		association :package, factory: :stock_package_fulfilled, strategy: :build

		initialize_with { new(package, :standard) }

		after(:build){|request| request.package.order.ship_address = request.package.order.bill_address }

    factory :fulfillment_preview_request_with_9_digit_zip do
      after(:build){|request| request.package.order.ship_address.zipcode = "932917939"}
    end
	end
end