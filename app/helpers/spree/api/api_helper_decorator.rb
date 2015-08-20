Spree::Api::ApiHelpers.class_eval do
  mattr_accessor :variant_attributes
end
Spree::Api::ApiHelpers.variant_attributes = Spree::Api::ApiHelpers.variant_attributes | [:fulfillment_subsidy]