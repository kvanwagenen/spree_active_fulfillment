require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FbaInventoryReportRequest do

    let(:request){ FbaInventoryReportRequest.new }

    before(:each) do
      klass = FbaInventoryReportRequest
      klass.send(:public, *(klass.private_instance_methods & klass.protected_instance_methods))
    end

    context '#report' do
      it 'returns an instance of FbaInventoryReport' do

      end

      it 'raises an exception if it takes longer than its timeout to run' do
        
      end
    end

  end
end