module Spree
  module Fulfillment
    class Configuration < Spree::Preferences::Configuration
      preference :mws_marketplace_id, :string
      preference :mws_merchant_id, :string
      preference :aws_access_key_id, :string
      preference :aws_secret_access_key, :string
      preference :amazon_stock_location_id, :integer

      def amazon_provider
        @amazon_provider ||= Providers::Amazon::AmazonProvider.new
      end
    end
  end
end