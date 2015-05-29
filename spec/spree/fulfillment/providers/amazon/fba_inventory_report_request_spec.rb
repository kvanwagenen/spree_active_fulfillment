require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FbaInventoryReportRequest do

    let(:get_report_request_list_response) do
      Nokogiri::XML(load_fixture("reports_get_report_request_list_example.xml"))
    end
    let(:request_report_response) do
      Nokogiri::XML(load_fixture("reports_request_report_response_example.xml"))
    end
    let(:get_report_response) do

    end
    let(:client) do
      client = double("Client")
      allow(client).to receive(:request_report).and_return(request_report_response)
      allow(client).to receive(:get_report_request_list).and_return(get_report_request_list_response)
      client
    end
    let(:request){ 
      request = FbaInventoryReportRequest.new
      allow(request).to receive(:client).and_return(client)
      request
    }

    before(:each) do
      klass = FbaInventoryReportRequest
      klass.send(:public, *klass.private_instance_methods)
    end

    context '#report' do
      it 'returns an instance of FbaInventoryReport' do

      end

      it 'raises an exception if it takes longer than its timeout to run' do
        
      end
    end

    context '#report_request_id' do
      it 'returns the expected request id' do
        expect(request.report_request_id).to eq("2291326454")
      end
    end

    context '#report_id' do
      it 'correctly parses the report id from the get report list response' do
        expect(request.get_report_id)
      end
    end

  end
end