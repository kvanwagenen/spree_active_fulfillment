require 'spec_helper'

describe Spree::Fulfillment::Providers::Amazon::FulfillmentPreviewRequest do
	let(:package){ build(:stock_package_fulfilled) }
	let(:request){ build(:standard_fulfillment_preview_request) }

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
			expect(request.preview).to be_instance_of(Spree::Fulfillment::Providers::Amazon::FulfillmentPreview)
		end
	end

end 