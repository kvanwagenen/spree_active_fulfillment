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
    let(:peddler_request){instance_double(PeddlerRequest)}
    let(:request){{body: "Request body", query: "Request query"}}
    let(:client) do
      client = double("MWS::FulfillmentOutboundShipment::Client")
      response = double("response", body: "Response body")
      allow(client).to receive(:cancel_fulfillment_order).and_raise(Excon::Errors::BadRequest.new("Message", request, response))
      client
    end
    let(:wrapper) do
      PeddlerClientWrapper.new(peddler_request, client)
    end

    context "with a failing call to #cancel_fulfillment_order" do
      
      it 'calls handle_error on the peddler request' do
        expect(peddler_request).to receive(:handle_error)
        expect{wrapper.cancel_fulfillment_order}.to raise_error(PeddlerError)
      end
      context 'when the peddler_request returns false' do
        it 'catches the error and raises a PeddlerError' do
          expect{wrapper.cancel_fulfillment_order}.to raise_error(PeddlerError)
        end
      end
      context 'when handle_error returns true' do
        before do
          allow(peddler_request).to receive(:handle_error).and_return(true)
        end
        it 'does not catch the error' do
          expect{wrapper.cancel_fulfillment_order}.not_to raise_error
        end
      end
    end
  end
end