Spree::Shipment.class_eval do
  has_many :fulfillments

  def fulfillment_provider
    (shipping_method && shipping_method.calculator && shipping_method.calculator.respond_to?(:fulfillment_provider)) ? shipping_method.calculator.fulfillment_provider : nil
  end

  def fulfillment_service
    shipping_method.calculator.service
  end

  def refresh_fulfillments(not_refreshed_for=0)
    fulfillments_to_refresh(not_refreshed_for).each do |fulfillment|
      fulfillment_provider.refresh_fulfillment(fulfillment)
    end
  end
  
  def fulfill!
    fulfillment_provider.fulfill(self, fulfillment_service)
  end

  alias_method :orig_after_cancel, :after_cancel
  def after_cancel
    orig_after_cancel
    fulfillments.each(&:cancel)
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

  private

  def fulfillments_to_refresh(not_refreshed_for)
    fulfillments.where("spree_fulfillments.updated_at < ?", DateTime.now - not_refreshed_for)
  end

end