class StoreController < ApplicationController
	include CurrentCart
	before_action :set_cart
	skip_before_action :authorize
  def index
  	@products = Product.order(:title)
  end


  def showcase
  	@products = Product.order(:title)
  end
 def showcase2
  	@products = Product.order(:title)
  end  
end
