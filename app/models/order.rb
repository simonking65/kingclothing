class Order < ActiveRecord::Base
	has_many :line_items, dependent: :destroy
	#attr_accessible :amount, :description, :state, :payment_method, :credit_card

	PAYMENT_TYPES = [ "Cheque", "Credit card", "Purchase order", "Paypal"]
	validates :name, :address, :email, presence: true
	validates :payment_method, inclusion: PAYMENT_TYPES

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
  	
    logger.info "about to @payment.create"
    # if payment_method == "credit_card" and !user.save
    #   raise ActiveRecord::Rollback, "Can't place the order"
    # end
    @payment = Payment.new( :order => self )
    debugger
    if @payment.create
      self.payment_id = @payment.id
      self.state      = @payment.state
      self.payment_method = "Paypal"
      self.pay_type = "paypal"
      save(validate: false)
      logger.info "@payment save just done"
      logger.info @payment.inspect
    else
      errors.add :payment_method, @payment.error["message"] if @payment.error
            logger.info "@payment.create failed #{@payment.error["message"]}"
      raise ActiveRecord::Rollback, "Can't place the order"
      logger.info "@payment.create failed #{@payment.error["message"]}"
    end
    logger.info payment.inspect
  end

  def execute(payer_id, payment_id)
  	
    #if payment.present?
      if payment = Payment.find(payment_id) 
        if payment.execute(:payer_id => payer_id)
          self.state = payment.state
          save
        else
          errors.add :description, payment.error.inspect
          false
        end
      else
        errors.add :description, payment.error.inspect
        false
      end
    #else
    #  errors.add :description, payment.error.inspect
    #  false
    #end
  end

  def confirm(payer_id, payment_id)
    debugger
    if payment = Payment.find(payment_id)
      debugger 
      
      self.name = payment.payer.payer_info.first_name + " " + payment.payer.payer_info.last_name
      self.email = payment.payer.payer_info.email
      self.address = payment.payer.payer_info.shipping_address.line1
      self.shipping_address1 = payment.payer.payer_info.shipping_address.line1
      save
      #return true
      #payment.execute(:payer_id => payer_id)
      
    else
      errors.add :description, payment.error.inspect
      false
    end
  end

  def approve_url
  	
    logger.info payment.inspect
    payment.links.find{|link| link.method == "REDIRECT" }.try(:href)
  end
	
	def total_price
		line_items.to_a.sum { |item| item.total_price }
	end
	
  def total_items
    debugger
    line_items.count
  end
  
	def subtotal
		line_items.to_a.sum { |item| item.total_price }
	end

end
