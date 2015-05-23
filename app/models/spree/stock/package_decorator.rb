Spree::Stock::Package.class_eval do

	SkuCount = Struct.new(:sku, :count)
	def sku_counts
		@contents
		  .map{|i|{ :sku => i.variant.sku, :count => i.quantity}}
      	  .group_by{|i|i[:sku]}.values
      	  .map{|v| SkuCount.new(v[0][:sku], v.sum{|sku|sku[:count]})}
	end

end