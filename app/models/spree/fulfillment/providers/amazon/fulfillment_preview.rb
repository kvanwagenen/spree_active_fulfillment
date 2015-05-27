module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreview

    def initialize(xml_parser)
      @xml = xml_parser
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

    private

    attr_reader :hash, :xml

    def hash
      @hash ||= xml_to_hash
    end

    # Returns a hash with the form:
    # { :standard => {
    #     :total => 1230,
    #     :earliest_arrival_date => <Some DateTime>,
    #     :latest_arrival_date => <Some DateTime>
    #   },
    #   :expedited => {
    #     ...
    #   }, ...
    # }
    #
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