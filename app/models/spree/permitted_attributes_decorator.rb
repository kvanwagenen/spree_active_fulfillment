Spree::PermittedAttributes.module_eval do
  mattr_accessor :variant_attributes
end
Spree::PermittedAttributes.variant_attributes = Spree::PermittedAttributes.variant_attributes | [:fulfillment_subsidy]