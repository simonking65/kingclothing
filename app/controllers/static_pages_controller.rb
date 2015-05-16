class StaticPagesController < ApplicationController
	include CurrentCart
	before_action :set_cart
	skip_before_action :authorize
  def home
  end

  def questions
  end

  def news
  end

  def contact
  end
end
