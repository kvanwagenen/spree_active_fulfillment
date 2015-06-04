class CreateSpreeFulfillments < ActiveRecord::Migration
  def change
    create_table :spree_fulfillments do |t|
      t.belongs_to :shipment, index: true, foreign_key: true
      t.string :status
      t.string :fulfiller_id
      t.string :service
      t.datetime :earliest_arrival_time
      t.datetime :latest_arrival_time
      t.datetime :time_received_by_fulfiller
      t.datetime :status_updated
      t.string :fulfillment_data
      t.timestamps null: false
    end
  end
end
