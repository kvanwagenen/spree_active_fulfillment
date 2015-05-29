FactoryGirl.define do

  factory :fulfillment_preview, class: Spree::Fulfillment::Providers::Amazon::FulfillmentPreview do
    response_xml = IO.read(File.join(SpecRoot::PATH, "fixtures", "fulfillment_preview_request_response_example.xml"))
    initialize_with { new(Nokogiri::XML(response_xml)) }
  end

end