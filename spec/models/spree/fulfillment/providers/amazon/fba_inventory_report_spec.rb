require 'spec_helper'

module Spree::Fulfillment::Providers::Amazon
  describe FbaInventoryReport do
    let(:report) do
      parsed_response = load_tab_delimited_fixture(File.join("reports", "get_report_response.txt"))
      report = FbaInventoryReport.new(parsed_response)
    end

    context "#sku_levels" do
      it 'should return a valid array of sku levels' do
        sku_levels = report.sku_levels
        expect(sku_levels).to be_kind_of(Array)
        expect(sku_levels.length).to eq(9)
        expect(sku_levels[0][:sku]).to eq("00115-S")
        expect(sku_levels[0][:on_hand]).to eq(31)
      end
    end

  end
end