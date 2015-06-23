require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FulfillmentOrder do
    let(:parsed_response) { load_xml_fixture("get_fulfillment_order_response_example.xml") }
    let(:fulfillment_order) do
      FulfillmentOrder.new(parsed_response)
    end

    context '#fulfillment' do
      subject(:fulfillment) { fulfillment_order.fulfillment }

      context 'with a processing fulfillment order' do            
        it 'should return a valid instance of Fulfillment' do
          expect(fulfillment).to be_instance_of(AmazonFulfillment)
          expect(fulfillment.shipment).to be_nil
          expect(fulfillment.status).to eq("processing")
          expect(fulfillment.fulfiller_id).to eq("extern_id_1154539615776")
          expect(fulfillment.service).to eq("expedited")
          expect(fulfillment.earliest_arrival_time).to eq(DateTime.new(2014,1,5,3,0,0))
          expect(fulfillment.latest_arrival_time).to eq(DateTime.new(2014,1,5,5,0,0))
          expect(fulfillment.time_received_by_fulfiller).to eq(DateTime.new(2014,1,2,17,26,56))
          expect(fulfillment.status_updated).to eq(DateTime.new(2014,1,2,23,48,48))
          expect(fulfillment.fulfillment_data[:shipments][1][:packages][0][:number]).to eq("1")
          expect(fulfillment.fulfillment_data[:shipments][1][:packages][0][:carrier_code]).to eq("UPS")
          expect(fulfillment.fulfillment_data[:shipments][1][:packages][0][:tracking_number]).to eq("93ZZ00")
        end
      end

      context 'with a received fulfillment order' do      
        let(:parsed_response) { load_xml_fixture("get_received_fulfillment_order_response_example.xml") }
      
        it 'handles empty dates' do
          expect(fulfillment.earliest_arrival_time).to be_nil
        end
      end
    end

    context '#cancelled?' do
      context 'with cancelled quantity elements greater than 0' do
        let(:parsed_response){load_xml_fixture("get_fulfillment_order_response_cancelled_example.xml")}
        it 'returns true' do
          expect(fulfillment_order.cancelled?).to eq(true)
        end
      end

      context 'with no CancelledQuantity elements' do
        let(:parsed_response){load_xml_fixture("get_fulfillment_order_response_none_cancelled_example.xml")}
        it 'returns false' do
          expect(fulfillment_order.cancelled?).to eq(false)
        end
      end

      context 'with sum of cancelled quantity elements 0' do
        let(:parsed_response){load_xml_fixture("get_fulfillment_order_response_example.xml")}
        it 'returns false' do
          expect(fulfillment_order.cancelled?).to eq(false)
        end
      end
    end
  end
end