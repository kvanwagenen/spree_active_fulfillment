require 'active_support/concern'
require_dependency 'spree/fulfillment/providers/amazon/create_fulfillment_order_request' # Includes error classes
module FulfillmentErrorConcerns
  extend ActiveSupport::Concern
  
  included do
    rescue_from Spree::Fulfillment::Providers::Amazon::FulfillmentError, with: :rescue_from_fulfillment_error
  end
  
  def rescue_from_fulfillment_error(e)
    if e.is_a?(Spree::Fulfillment::Providers::Amazon::InventoryNotAvailable)
      Spree::FulfillmentConfig.amazon_provider.update_inventory_levels(@order.line_items.map(&:variant))
      flash[:error] = Spree.t(:insufficient_inventory_exists_to_fulfill_your_order)
      redirect_to cart_path
    elsif e.is_a?(Spree::Fulfillment::Providers::Amazon::OnlyStandardServiceAvailableForDestination)
      @order.fulfilled_shipments.each do |shipment|
        shipment.shipping_rates.select{|rate|[:priority, :expedited].include?(rate.shipping_method.calculator.service)}.each(&:delete)
      end
      flash[:error] = Spree.t(:only_standard_shipping_available_to_destination)
      redirect_to checkout_state_path(:delivery)
    else
      flash[:error] = Spree.t(:fulfillment_error)
      redirect_to checkout_state_path(:confirm)
    end
    refund_completed_payments
  end
  
  def refund_completed_payments
    refund_reason = Spree::RefundReason.find_or_create_by(name: "Failed Fulfillment")
    @order.payments.completed.each do |payment|
      payment.refunds.create(amount: payment.amount, refund_reason_id: refund_reason.id)
    end
    @order.payments.pending.each do |payment|
      payment.try(:void_transaction!)
    end
  end
end