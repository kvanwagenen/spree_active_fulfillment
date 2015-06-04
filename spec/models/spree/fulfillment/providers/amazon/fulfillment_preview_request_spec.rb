require 'spec_helper'

describe Spree::Fulfillment::Providers::Amazon::FulfillmentPreviewRequest do
	let(:package){ build(:stock_package_fulfilled) }
	let(:request){ build(:standard_fulfillment_preview_request) }

	let(:example_response) do
		xml = IO.read(File.join(SpecRoot::PATH,"fixtures","fulfillment_preview_request_response_example.xml"))
		Nokogiri::XML(xml)
	end

	before :each do
		klass = Spree::Fulfillment::Providers::Amazon::FulfillmentPreviewRequest
		klass.send(:public, *klass.private_instance_methods)
	end

	context '#address' do
		it 'returns a hash with an MWS address from the ship address' do
			address = request.address
			expect(address).to be_instance_of(Hash)
			expect(address['Name']).not_to be_nil
			expect(address['Line1']).not_to be_nil
			expect(address['City']).not_to be_nil
			expect(address['CountryCode']).to eq('US')
		end

		context 'with a 9 digit zip' do
			let(:request){ build(:fulfillment_preview_request_with_9_digit_zip) }

			it 'passes only the first 5 digits of the postal code' do
				address = request.address
				expect(address['PostalCode'].length).to eq(5)
			end
		end
		
	end

	context '#items' do
		it 'returns an array of MWS preview item hashes' do
			items = request.items
			expect(items).to be_instance_of(Array)
			expect(items[0]).to be_instance_of(Hash)
			expect(items[0]['Quantity']).to be_kind_of(Integer)
			expect(items[0]['SellerSKU']).to be_instance_of(String)
		end
	end

	context '#preview' do
		it 'returns an instance of FulfillmentPreview' do
			allow(request).to receive(:parsed_response_xml).and_return(example_response)
			expect(request.preview).to be_instance_of(Spree::Fulfillment::Providers::Amazon::FulfillmentPreview)
		end
	end

end 