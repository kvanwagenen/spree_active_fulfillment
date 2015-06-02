module Spree::Fulfillment::Providers::Amazon
  class NokogiriParser
    def initialize(res, encoding)
      @xml = Nokogiri::XML(res.body)
    end

    private

    def method_missing(method, *args, &block)
      @xml.send(method, *args, &block)
    end
  end

  class PeddlerRequest

    protected

    def aws_merchant_credentials
      {
        marketplace_id: config.preferred_mws_marketplace_id,
        merchant_id: config.preferred_mws_merchant_id,
        aws_access_key_id: config.preferred_aws_access_key_id,
        aws_secret_access_key: config.preferred_aws_secret_access_key
      }
    end

    def client(parser=NokogiriParser)
      client_class.parser = parser
      @client ||= client_class.new(aws_merchant_credentials)
    end

    def client_class
      raise NotImplementedError "#client_class has not been implemented on this request!"
    end

    private

    def config
      Spree::Fulfillment::Config
    end

  end
end