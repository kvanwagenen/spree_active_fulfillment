require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FbaInventoryReportRequest do

    let(:get_report_request_list_response) do
      load_xml_fixture(File.join("reports","get_report_request_list_response.xml"))
    end
    let(:request_report_response) do
      load_xml_fixture(File.join("reports","request_report_response.xml"))
    end
    let(:get_report_list_response) do
      load_xml_fixture(File.join("reports","get_report_list_response.xml"))
    end
    let(:get_report_response) do
      load_tab_delimited_fixture(File.join("reports","get_report_response.txt"))
    end    
    let(:client) do
      client = double("Client")
      allow(client).to receive(:request_report).and_return(request_report_response)
      allow(client).to receive(:get_report_request_list).and_return(get_report_request_list_response)
      allow(client).to receive(:get_report_list).and_return(get_report_list_response)
      allow(client).to receive(:get_report).and_return(get_report_response)
      client
    end
    let(:request) do
      request = FbaInventoryReportRequest.new(load_most_recent: false)
      allow(request).to receive(:client).and_return(client)
      request
    end

    before(:each) do
      klass = FbaInventoryReportRequest
      klass.send(:public, *klass.private_instance_methods)
    end

    context '#report' do
      it 'returns an instance of FbaInventoryReport' do
        expect(request.report).to be_instance_of(FbaInventoryReport)
      end

      it 'raises an exception if it takes longer than expected to run' do
        allow(request).to receive(:request_timeout).and_return(0.1)
        allow(request).to receive(:report_status).and_return("_PROCESSING_")
        expect{request.report}.to raise_error(ReportTimeoutError)
      end
    end

    context '#report_request_id' do
      it 'returns the expected request id' do
        expect(request.report_request_id).to eq("2291326454")
      end
    end

    context '#report_id' do
      it 'correctly parses the report id from the get report list response' do
        expect(request.report_id).to eq("898899473")
      end

      it 'correctly retrieves the report id of the most recent report' do
        allow(request).to receive(:load_most_recent).and_return(true)
        expect(request.report_id).to eq("898899474")
      end
    end

    context '#report_status' do
      it 'correctly parses the status from the request list response' do
        expect(request.report_status).to eq("_DONE_")
      end
    end

  end
end