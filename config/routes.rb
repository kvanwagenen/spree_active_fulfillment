Spree::Core::Engine.routes.draw do
  namespace :api do
    namespace :fulfillment do
      put "/amazon/update_inventory", to: "amazon#update_inventory", as: :update_amazon_inventory
    end
  end  
end
