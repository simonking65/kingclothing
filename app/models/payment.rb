class Payment < PayPal::SDK::REST::Payment
  include ActiveModel::Validations

  def create
    debugger
    logger.info "in payment.create"
    logger.info self.to_hash
    return false if invalid?
    logger.info "got past invalid"
    super
    logger.info "back from super"
  end

  def error=(error)
    error["details"].each do |detail|
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
    debugger
    self.intent = "sale"
    add_payment_method(order)
    self.transactions = {
      :amount => {
        :total => order.total_price,
        :currency => "USD" },
      :item_list => {
        :items => { :name => "pizza", :sku => "pizza", :price => order.total_price, :currency => "USD", :quantity => 1 }
      },
      #:description => order.description
      :description => "my test"
     }
     self.redirect_urls = {
       :return_url => order.return_url.sub(/:order_id/, order.id.to_s),
       :cancel_url => order.cancel_url.sub(/:order_id/, order.id.to_s)
     }
     logger.info "in order="
  end

end
