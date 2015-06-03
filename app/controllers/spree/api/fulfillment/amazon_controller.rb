module Spree::Api
  module Fulfillment
    class AmazonController < Spree::Api::BaseController

      def update_inventory
        authorize! :update, Spree::StockItem
        amazon_provider.update_inventory_levels(variants_to_update)
        render json: {updated_variants: variants_to_update.map(&:id)}, status: :ok
      end

      private

      def amazon_provider
        Spree::Fulfillment::Config.amazon_provider
      end

      def variants_to_update
        @variants_to_update ||= begin
          Spree::Variant.where(sku: skus_to_update)
        end
      end

      def skus_to_update
        update_inventory_params[:skus]
      end
      
      def update_inventory_params
        params.permit(skus: [])
      end

    end
  end
end