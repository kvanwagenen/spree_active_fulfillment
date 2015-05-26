module Spree::Fulfillment::Providers::Amazon
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

    private

    def config
      Spree::Fulfillment::Config
    end

  end
end