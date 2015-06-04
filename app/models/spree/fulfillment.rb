module Spree
  class Fulfillment < ActiveRecord::Base
    belongs_to :shipment

    serialize :fulfillment_data
  end
end