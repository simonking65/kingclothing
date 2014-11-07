class StaticPagesController < ApplicationController
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
