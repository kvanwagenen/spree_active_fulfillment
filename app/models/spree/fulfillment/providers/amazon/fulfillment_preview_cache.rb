module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreviewCache

    def initialize(provider)
      @provider = provider
      @previews = {}
    end

    def get(package, service)
      key = preview_key(package, service)
      previews[key] ||= FulfillmentPreviewRequest.new(package, service, provider).preview
    end

    private

    attr_accessor :previews, :provider

    def preview_key(package, service)
      "#{zip(package)}:#{contents(package)}:#{service.to_s}"
    end

    def zip(package)
      package.order.ship_address.zipcode.to_s
    end

    def contents(package)
      items = package.contents.map{|i|{ :sku => i.variant.sku, :count => i.quantity}}
      items.group_by{|i|i[:sku]}.values.map{|v|{:sku => v[0][:sku], :count => v.sum{|sku|sku[:count]}}}
      items.to_json
    end 

  end
end