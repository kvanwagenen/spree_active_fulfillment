module SpreeFulfillment
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_fulfillment'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_fulfillment.init_configuration', :before => :load_config_initializers do
      Spree::Fulfillment::Config = Spree::Fulfillment::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
