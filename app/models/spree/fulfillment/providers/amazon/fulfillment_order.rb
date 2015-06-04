module Spree::Fulfillment::Providers::Amazon
  class FulfillmentOrder

    def initialize(parsed_xml)
      @xml = parsed_xml
    end

    def fulfillment
      Spree::Fulfillment.new(
        status: status,
        fulfiller_id: fulfiller_id
      )
    end

    def update_fulfillment(fulfillment)
      
    end

    private



  end
end