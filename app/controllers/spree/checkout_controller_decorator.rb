require_dependency 'spree/fulfillment/providers/amazon/create_fulfillment_order_request'
Spree::CheckoutController.class_eval do
  include FulfillmentErrorConcerns
end