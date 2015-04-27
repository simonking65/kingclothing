class AddScaleToItemPrice < ActiveRecord::Migration
  def change
  	change_column :line_items, :productprice, :decimal , precision: 8, scale: 2
  end
end
