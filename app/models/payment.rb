class Payment < PayPal::SDK::REST::Payment
  include ActiveModel::Validations

  def create
    
    logger.info "in payment.create"
    logger.info self.to_hash
    invreturn = invalid?
    logger.info errors.inspect
    return false if invreturn
    logger.info "got past invalid"
    super
    logger.info "back from super"
    logger.info self.to_hash
  end

  def error=(error)
    error["details"].each do |detail|
      logger.info " in error="
      errors.add detail["field"], detail["issue"]
    end if error and error["details"]
    super
  end


  def add_payment_method(order)
    #user = order.user
    #if order.payment_method == "credit_card" and user.credit_card_id
    #  self.payer.payment_method = "credit_card"
    #  self.payer.funding_instruments = {
    #    :credit_card_token => {
    #      :credit_card_id => user.credit_card_id,
    #      :payer_id => user.email }}
    #else
      self.payer.payment_method = "paypal"
    #end
  end

  def order=(order)
    self.intent = "sale"
    add_payment_method(order)
#    debugger
    #self.transactions = {
    #  :amount => {
    #    :total => order.total_price,
    #    :currency => "GBP" },
    #  :item_list => {
    #    :items => { :name => "Tee Shirts", :sku => "Tee Shirts", :price => 18.99, :currency => "GBP", :quantity => 1
    #       }
    #  },
    #  #:description => order.description
    #  :description => "King Clothing"
    # }
         self.transactions = {
      :amount => {
        :total => order.total_price,
        :currency => "GBP" },
     # :item_list => {
     #   :items => { :name => "Tee Shirts", :sku => "Tee Shirts", :price => 18.99, :currency => "GBP", :quantity => 1
     #      }
     # },
      #:description => order.description
      :description => "King Clothing"
     }

     order.line_items.each do |item|

        self.transactions[0].item_list.items.merge!( { :name => item.product.title, :sku => item.product.title, :price => item.productprice, :currency => "GBP", :quantity => item.quantity } )
      end
     #self.transactions[0].item_list.items.merge!( { :name => "penknife", :sku => "PK1", :price => 12.99, :currency => "GBP", :quantity => 1 })
     #self.transactions[0].item_list.items.merge!( { :name => "tee shirt", :sku => "ts1", :price => 10.99, :currency => "GBP", :quantity => 1 })

     
     #self.transactions << { :name => "penknife", :sku => "PK1", :price => 2, :currency => "GBP", :quantity => 1 }
#     self.transactions[0] << { :item_list => 
 #       { :items => { :name => "penknife", :sku => "PK1", :price => 14.99, :currency => "GBP", :quantity => 1 }
   #    }, 
    #   :description => "King Clothing" 
    #  }
   #  debugger
     self.redirect_urls = {
       :return_url => order.return_url.sub(/:order_id/, order.id.to_s),
       :cancel_url => order.cancel_url.sub(/:order_id/, order.id.to_s)
     }
     logger.info "in order="
  end

end
