module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreview

    def initialize(parsed_xml)
      @xml = parsed_xml
    end

    def total_cost(service)
      hash[service][:total]
    end

    DeliveryDateEstimate = Struct.new(:earliest, :latest)
    def delivery_date_estimate(service)
      DeliveryDateEstimate.new(
        hash[service][:earliest_arrival_date],
        hash[service][:latest_arrival_date]
      )
    end

    def fulfillable?(service)
      hash[service][:fulfillable]
    end

    private

    attr_reader :hash, :xml

    def hash
      @hash ||= xml_to_hash
    end

    def xml_to_hash
      hash = {}
      members = xml.css("FulfillmentPreviews > member")
      members.each do |preview|
        speed = preview.css("ShippingSpeedCategory").text.downcase.to_sym
        hash[speed] = {}
        total = preview.css("EstimatedFees Value").inject(0){|m,n| m += n.text.to_i}
        hash[speed][:total] = total
        earliest_arrival_dates = dates_from_nodes(preview.css("EarliestArrivalDate"))
        hash[speed][:earliest_arrival_date] = earliest_arrival_dates.min
        latest_arrival_dates = dates_from_nodes(preview.css("LatestArrivalDate"))
        hash[speed][:latest_arrival_date] = latest_arrival_dates.max
        fulfillable = preview.css("IsFulfillable").text.downcase == "true"
        hash[speed][:fulfillable] = fulfillable
      end
      hash
    end

    def dates_from_nodes(nodes)
      nodes.map{|n| parse_amazon_date(n.text)}
    end

    def parse_amazon_date(date_string)
      DateTime.strptime(date_string, "%Y-%m-%dT%H:%M:%SZ")
    end

  end
end