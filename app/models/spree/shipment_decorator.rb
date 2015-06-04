Spree::Shipment.class_eval do
  has_many :fulfillments

  def fulfillment_provider
    shipping_method.calculator.respond_to?(:fulfillment_provider) ? shipping_method.calculator.fulfillment_provider : nil
  end

  def fulfillment_service
    shipping_method.calculator.service
  end

  alias_method :orig_finalize!, :finalize!
  def finalize!
    orig_finalize!
    if fulfillment_provider
      fulfillment_provider.fulfill(self, fulfillment_service)
    end
  end

  def sku_counts
    sku_units = inventory_units.group_by{|i|i.variant.sku}
    sku_units.map do |sku, units|
      {
        sku: sku,
        count: units.length
      }
    end
  end

end