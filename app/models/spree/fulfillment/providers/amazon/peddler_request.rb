module Spree::Fulfillment::Providers::Amazon
  class FlexibleParser
    def initialize(res, encoding)
      return res unless res.body
      if res.headers['Content-Type'].start_with?('text/xml')
        @parser = Nokogiri::XML(res.body)
      else
        @parser = CSV.parse(res.body, col_sep: "\t", quote_char: "\x00", headers: true)
      end
    end

    private

    def method_missing(method, *args, &block)
      @parser.send(method, *args, &block)
    end
  end

  class PeddlerRequest

    protected

    def client_class
      raise NotImplementedError "#client_class has not been implemented on this request!"
    end

    def aws_merchant_credentials
      {
        marketplace_id: config.preferred_mws_marketplace_id,
        merchant_id: config.preferred_mws_merchant_id,
        aws_access_key_id: config.preferred_aws_access_key_id,
        aws_secret_access_key: config.preferred_aws_secret_access_key
      }
    end

    def client
      @client ||= begin
        client_class.parser = FlexibleParser
        PeddlerClientWrapper.new(client_class.new(aws_merchant_credentials))
      end
    end

    def logger
      Rails.logger
    end

    private

    def config
      Spree::Fulfillment::Config
    end

  end

  class PeddlerClientWrapper
    def initialize(client)
      @client = client
    end

    private

    attr_reader :client

    def method_missing(method, *args, &block)
      begin
        client.send(method, *args, &block)
      rescue Excon::Errors::HTTPStatusError => e
        logger.error e
        logger.error "#{self.class.name} failed! Error: #{e.to_s}\nRequest:\n#{e.request.body}\n\nResponse:\n#{e.response.body}"
        raise PeddlerError.new "Peddler request failed!"
      end
    end

    def logger
      Rails.logger
    end
  end

  class PeddlerError < StandardError; end
end