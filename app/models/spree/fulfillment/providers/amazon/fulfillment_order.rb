module Spree::Fulfillment::Providers::Amazon
  class FulfillmentOrder

    def initialize(parsed_xml)
      @xml = parsed_xml
    end

    def fulfillment
      new_fulfillment
    end

    def update_fulfillment(fulfillment)
      fulfillment.update(fulfillment_attributes)
      updated_fulfillment(fulfillment)
    end

    def cancelled?
      xml.css("CancelledQuantity").inject(0){|sum,n|sum + n.text.to_i} > 0
    end

    private
    
    def new_fulfillment
      AmazonFulfillment.new(fulfillment_attributes)
    end
    
    def fulfillment_attributes
      {
        status: status,
        fulfiller_id: fulfiller_id,
        service: service,
        earliest_arrival_time: earliest_arrival_time,
        latest_arrival_time: latest_arrival_time,
        time_received_by_fulfiller: time_received_by_fulfiller,
        status_updated: status_updated,
        fulfillment_data: fulfillment_data
      }
    end

    attr_reader :xml

    def status
      xml.css("FulfillmentOrderStatus").text.downcase
    end

    def fulfiller_id
      xml.css("SellerFulfillmentOrderId").text.strip
    end

    def service
      xml.css("ShippingSpeedCategory").text.downcase
    end

    def earliest_arrival_time
      FbaUtils.parse_amazon_date(xml.css("DeliveryWindow StartDateTime").text)
    end

    def latest_arrival_time
      FbaUtils.parse_amazon_date(xml.css("DeliveryWindow EndDateTime").text)
    end

    def time_received_by_fulfiller
      FbaUtils.parse_amazon_date(xml.css("ReceivedDateTime").text)
    end

    def status_updated
      FbaUtils.parse_amazon_date(xml.css("StatusUpdatedDateTime").text)
    end

    def fulfillment_data
      data = {}
      data[:shipments] = xml.css("FulfillmentShipment > member").map do |shipment_xml|
        shipment_hash(shipment_xml)
      end
      data
    end

    def shipment_hash(shipment_xml)
      shipment = {}
      shipment[:status] = shipment_xml.css("FulfillmentShipmentStatus").text.downcase
      shipment[:packages] = shipment_xml.css("FulfillmentShipmentPackage > member").map do |package_xml|
        package_hash(package_xml)
      end
      shipment
    end

    def package_hash(package_xml)
      {
        number: package_xml.css("PackageNumber").text,
        carrier_code: package_xml.css("CarrierCode").text,
        tracking_number: package_xml.css("TrackingNumber").text
      }
    end

  end
end