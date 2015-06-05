namespace :spree_fulfillment do
  task :refresh_fulfillments => :environment do
    Rails.application.eager_load!
    watcher = Spree::Fulfillment::Providers::Amazon::FulfillmentWatcher.new
    watcher.refresh_fulfillments    
  end
end