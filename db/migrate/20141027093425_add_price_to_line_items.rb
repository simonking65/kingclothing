class AddPriceToLineItems < ActiveRecord::Migration
  def up
  	add_column :line_items, :productprice, :decimal
  	LineItem.all.each do |l|
  		l.productprice = l.product.price
  		l.save
  	end
  end
  def down
  	remove_column :line_items, :productprice
  end
end
