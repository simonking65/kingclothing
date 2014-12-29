class AddShippingAddress1ToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :shipping_address1, :string
  end
end
