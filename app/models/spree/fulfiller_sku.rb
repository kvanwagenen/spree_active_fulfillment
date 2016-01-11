module Spree
  class FulfillerSku < ActiveRecord::Base
    belongs_to :variant
    
    validates :value, uniqueness: true
  end
end