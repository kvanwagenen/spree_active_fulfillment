Spree::Order.class_eval do
  state_machines[:state].before_transition to: :complete, do: :create_fulfillment_orders
  
  def create_fulfillment_orders
    fulfilled_shipments.each(&:fulfill!)
  end
  
  def fulfilled_shipments
    shipments.select{|s|s.fulfillment_provider}
  end
end