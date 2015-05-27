module Spree::Fulfillment::Providers::Amazon
  class NokogiriParser
    def self.parse(xml)
      Nokogiri::XML(xml)
    end
  end

  MWS::FulfillmentOutboundShipment::Client.parser = NokogiriParser
end