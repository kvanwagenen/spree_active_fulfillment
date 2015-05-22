module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreview

    def initialize(response_xml)
      @xml = response_xml
    end

    def cost

    end

    def delivery_date_estimate

    end

    private

    attr_accessor :xml

  end
end