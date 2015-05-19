require 'rspec'
require 'active_shipping'
require 'peddler'
require 'active_shipping/carriers/amazon_outbound_shipments'

Rspec.configure do |config|
  config.mock_with :rspec
  config.color = true
  config.order = "random"
end

describe ActiveShipping::Carriers::AmazonOutboundShipments do

  context '#find_rates' do
    let :amazon_outbound do
      ActiveShipping::Carriers::AmazonMws.new(
        marketplace_id: "",
        merchant_id: "",
        aws_access_key_id: "",
        aws_secret_access_key: ""
      )
    end
    let :origin do
      ActiveShipping::Location.new(
        country: 'US',
        state: 'CA',
        city: 'Beverly Hills',
        zip: '90210'
      )
    end
    let :destination do
      ActiveShipping::Location.new(
        country: 'US',
        state: 'NY',
        city: 'New York',
        zip: '10001'
      )
    end
    let :packages do
      [
        {

        },
        {

        }
      ]
      ActiveShipping::
    end

    it 'should return an ActiveShipping::RateResponse' do
      response = amazon_outbound.find_rates(
        origin,
        destination,
        packages
      )
      expect(amazon_outbound.find_rates()).to be_instance_of(ActiveShipping::RateResponse)
    end

    it 'should return rates with all necessary fields set' do
      rate = amazon_outbound.find_rates()[0]
      expect(rate.
    end

    it 'should return all rates returned from the mws client' do

    end

  end

end