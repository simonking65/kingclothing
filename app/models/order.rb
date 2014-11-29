class Order < ActiveRecord::Base
	has_many :line_items, dependent: :destroy
	#attr_accessible :amount, :description, :state, :payment_method, :credit_card

	PAYMENT_TYPES = [ "Cheque", "Credit card", "Purchase order", "Paypal"]
	validates :name, :address, :email, presence: true
	validates :pay_type, inclusion: PAYMENT_TYPES

after_create :create_payment
attr_accessor :return_url, :cancel_url, :payment_method
	def add_line_items_from_cart(cart)
		cart.line_items.each do |item|
			item.cart_id = nil
			line_items << item
		end
	end

	def payment
    @payment ||= payment_id && Payment.find(payment_id)
  end

  def credit_card
    user.credit_card
  end

  def credit_card=(hash)
    user.credit_card = hash
  end

  #def payment_method=paymeth 
#    @payment_method=paymeth
#  end

  def create_payment
  	payment_method = "paypal"
  	debugger
    # if payment_method == "credit_card" and !user.save
    #   raise ActiveRecord::Rollback, "Can't place the order"
    # end
    @payment = Payment.new( :order => self )
    if @payment.create
      self.payment_id = @payment.id
      self.state      = @payment.state
      save
      puts "@payment save just done"
      puts @payment.inspect
    else
      errors.add :payment_method, @payment.error["message"] if @payment.error
      raise ActiveRecord::Rollback, "Can't place the order"
    end
    logger.info payment.to_s
  end

  def execute(payer_id)
  	debugger
    if payment.present? and payment.execute(:payer_id => payer_id)
      self.state = payment.state
      save
    else
      errors.add :description, payment.error.inspect
      false
    end
  end



  def approve_url
  	debugger
    payment.links.find{|link| link.method == "REDIRECT" }.try(:href)
  end
	
	def total_price
		line_items.to_a.sum { |item| item.total_price }
	end
	
	def subtotal
		line_items.to_a.sum { |item| item.total_price }
	end

end
