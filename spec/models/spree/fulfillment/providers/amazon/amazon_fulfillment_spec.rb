require 'spec_helper'

module Spree
fulfillment_class = Fulfillment::Providers::Amazon::AmazonFulfillment
describe fulfillment_class, type: :model do
  context 'refreshable' do
    let(:unshipped_shipment){create(:shipment, state: 'ready')}
    let(:shipped_shipment){create(:shipment, state: 'shipped')}
    let!(:complete_unshipped_fulfillment) do
      fulfillment_class.create(
        shipment: unshipped_shipment,
        status: 'complete'
      )
    end
    let!(:complete_shipped_fulfillment) do
      fulfillment_class.create(
        shipment: shipped_shipment,
        status: 'complete'
      )
    end
    let!(:received_fulfillment) do
      fulfillment_class.create(
        shipment: unshipped_shipment,
        status: 'received'
      )
    end
    let!(:planning_fulfillment) do
      fulfillment_class.create(
        shipment: unshipped_shipment,
        status: 'planning'
      )
    end
    let!(:processing_fulfillment) do
      fulfillment_class.create(
        shipment: unshipped_shipment,
        status: 'processing'
      )
    end
    let(:refreshable){fulfillment_class.refreshable}
    it 'includes complete fulfillment with unshipped shipment' do
      expect(refreshable).to include(complete_unshipped_fulfillment)
    end
    it 'includes received fulfillment' do
      expect(refreshable).to include(received_fulfillment)
    end
    it 'includes planning fulfillment' do
      expect(refreshable).to include(planning_fulfillment)
    end
    it 'includes processing fulfillment' do
      expect(refreshable).to include(processing_fulfillment)
    end
    it 'excludes complete fulfillment with shipped shipment' do
      expect(refreshable).not_to include(complete_shipped_fulfillment)
    end
  end
  context '#status=' do
    context 'with no previous status' do
      context 'transitioning to received' do
        
      end
    end
    context 'with previous status of received' do
      context 'transitioning to planning' do
        
      end
      context 'transitioning to processing' do
        
      end
    end
    context 'with previous status of planning' do
      context 'transitioning to processing' do
        
      end
    end
    context 'with previous status of processing' do
      context 'transitioning to complete' do
        
      end
      context 'transitioning to complete_partialed' do
        
      end
      context 'transitioning to unfulfillable' do
        
      end
      context 'transitioning to invalid' do
        
      end
      context 'transitioning to cancelled' do
        
      end
    end
  end
end
end