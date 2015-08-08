namespace :spree_fulfillment do
  task :refresh_fulfillments => :environment do
    Rails.application.eager_load!
    watcher = Spree::Fulfillment::Providers::Amazon::FulfillmentWatcher.new
    watcher.refresh_fulfillments    
  end

  task :sync_inventory_levels => :environment do
    Rails.application.eager_load!
    Spree::Fulfillment::Config.amazon_provider.update_inventory_levels
  end
end