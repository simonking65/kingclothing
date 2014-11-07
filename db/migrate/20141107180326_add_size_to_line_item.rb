class AddSizeToLineItem < ActiveRecord::Migration
 	def up
  	add_column :line_items, :size, :string
  end
  def down
  	remove_column :line_items, :size
  end
end
