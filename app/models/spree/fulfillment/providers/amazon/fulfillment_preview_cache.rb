module Spree::Fulfillment::Providers::Amazon
  class FulfillmentPreviewCache

    def initialize
      @previews = {}
    end

    def get(package, service)
      key = preview_key(package, service)
      previews[key] ||= FulfillmentPreviewRequest.new(package, service).preview
    end

    private

    attr_accessor :previews

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