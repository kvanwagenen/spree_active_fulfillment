require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe PeddlerRequest do
    let(:klass){ PeddlerRequest }
    let(:request) do
      request = PeddlerRequest.new
      allow(request).to receive(:client_class).and_return(::MWS::FulfillmentOutboundShipment::Client)
      request
    end

    before(:each) do
      klass.send(:public, *klass.private_instance_methods)
      klass.send(:public, *klass.protected_instance_methods)
    end

    context "#client" do
      it 'returns an instance of ClientWrapper' do
        expect(request.client).to be_instance_of(PeddlerClientWrapper)
      end
    end
  end

  describe PeddlerClientWrapper do
    let(:client) do
      client = double("MWS::FulfillmentOutboundShipment::Client")
      request = double("request", body: "Request body")
      response = double("response", body: "Response body")
      allow(client).to receive(:cancel_fulfillment_order).and_raise(Excon::Errors::BadRequest.new("Message", request, response))
      client
    end
    let(:wrapper) do
      PeddlerClientWrapper.new(client)
    end

    context "with a failing call to #cancel_fulfillment_order" do
      it 'catches the error and raises a PeddlerError' do
        expect{wrapper.cancel_fulfillment_order}.to raise_error(PeddlerError)
      end
    end
  end
end