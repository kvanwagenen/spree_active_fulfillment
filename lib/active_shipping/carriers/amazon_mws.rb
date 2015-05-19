module ActiveShipping
	class AmazonMws < Carrier

		# Asks the carrier for rate estimates for a given shipment.
	    #
	    # @note Override with whatever you need to get the rates from the carrier.
	    #
	    # @param origin [ActiveShipping::Location] Where the shipment will originate from.
	    # @param destination [ActiveShipping::Location] Where the package will go.
	    # @param packages [Array<ActiveShipping::Package>] The list of packages that will
	    #   be in the shipment.
	    # @param options [Hash] Carrier-specific parameters.
	    # @return [ActiveShipping::RateResponse] The response from the carrier, which
	    #   includes 0 or more rate estimates for different shipping products
	    def find_rates(origin, destination, packages, options = {})
	      rate_response(origin, destination, packages, options)
	    end

	    # Registers a new shipment with the carrier, to get a tracking number and
	    # potentially shipping labels
	    #
	    # @note Override with whatever you need to register a shipment, and obtain
	    #   shipping labels if supported by the carrier.
	    #
	    # @param origin [ActiveShipping::Location] Where the shipment will originate from.
	    # @param destination [ActiveShipping::Location] Where the package will go.
	    # @param packages [Array<ActiveShipping::Package>] The list of packages that will
	    #   be in the shipment.
	    # @param options [Hash] Carrier-specific parameters.
	    # @return [ActiveShipping::ShipmentResponse] The response from the carrier. This
	    #   response should include a shipment identifier or tracking_number if successful,
	    #   and potentially shipping labels.
	    def create_shipment(origin, destination, packages, options = {})
	      raise NotImplementedError, "#create_shipment is not supported by #{self.class.name}."
	    end

	    # Retrieves tracking information for a previous shipment
	    #
	    # @note Override with whatever you need to get a shipping label
	    #
	    # @param tracking_number [String] The unique identifier of the shipment to track.
	    # @param options [Hash] Carrier-specific parameters.
	    # @return [ActiveShipping::TrackingResponse] The response from the carrier. This
	    #   response should a list of shipment tracking events if successful.
	    def find_tracking_info(tracking_number, options = {})
	      raise NotImplementedError, "#find_tracking_info is not supported by #{self.class.name}."
	    end

	    # Validate credentials with a call to the API.
	    #
	    # By default this just does a `find_rates` call with the orgin and destination both as
	    # the carrier's default_location. Override to provide alternate functionality, such as
	    # checking for `test_mode` to use test servers, etc.
	    #
	    # @return [Boolean] Should return `true` if the provided credentials proved to work,
	    #   `false` otherswise.
	    def valid_credentials?
	      location = self.class.default_location
	      find_rates(location, location, Package.new(100, [5, 15, 30]), :test => test_mode)
	    rescue ActiveShipping::ResponseError
	      false
	    else
	      true
	    end

	    # The maximum weight the carrier will accept.
	    # @return [Quantified::Mass]
	    def maximum_weight
	      Mass.new(150, :pounds)
	    end

	    protected

	    def requirements
			[:marketplace_id, :merchant_id, :aws_access_key_id, :aws_secret_access_key]
		end

		private

		def rate_response(origin, destination, packages, options)

		end

		def mws_client
			if !@mws_client
				@mws_client = MWS::FulfillmentOutboundShipment::Client.new(
					
				)
			end
			@mws_client
		end


	end
end