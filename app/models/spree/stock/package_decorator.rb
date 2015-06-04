Spree::Stock::Package.class_eval do

	def sku_counts
		@contents
		  .map{|i|{ :sku => i.variant.sku, :count => i.quantity}}
      	  .group_by{|i|i[:sku]}.values
      	  .map{|v| {sku: v[0][:sku], count: v.sum{|sku|sku[:count]}} }
	end

end