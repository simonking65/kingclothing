class PaypalExpressController < ApplicationController
  include CurrentCart
  #require 'paypal_sdk_merchant'
  before_filter :set_cart

 
  #include ActiveMerchant::Billing
  #include PaypalExpressHelper
 
  def checkout
    PayPal::SDK.configure({
      :mode => "sandbox",
      :username => "simon.king65-facilitator_api1.gmail.com",
      :password => "MLP7C4HCMZTT6A7Y",
      :signature => "AcbkD2jLSn.hCPB3rhfsE5wX8zSMAvxbibNzxPzROTihhXQOhWvagcfE"
      })
    @api = PayPal::SDK::Merchant::API.new
      @set_express_checkout = @api.build_set_express_checkout({
        :Version => "104.0",
        :SetExpressCheckoutRequestDetails => {
          :ReturnURL => "https://devtools-paypal.com/guide/expresscheckout/ruby?success=true",
          :CancelURL => "https://devtools-paypal.com/guide/expresscheckout/ruby?cancel=true",
          :PaymentDetails => [{
            :OrderTotal =>{
              :currencyID => "GBP",
              :value => "1.00"},
            :PaymentAction => "Sale"}]
        }
        })
#      debugger
      @set_express_checkout_response = @api.set_express_checkout(@set_express_checkout)
# debugger
   # total_as_cents, setup_purchase_params = get_setup_purchase_params @cart, request
   # setup_response = @gateway.setup_purchase(total_as_cents, setup_purchase_params)
   # debugger
   # redirect_to @gateway.redirect_url_for(setup_response.token)
  #response = EXPRESS_GATEWAY.setup_purchase(20, 
   # ip: request.remote_ip,
    #return_url: "www.kingclothing.com",
   # cancel_return_url: "cancel.kingclothing.com",
   # currency: "GBP". 
  #  allow_guest_checkout: true,
  #  items: [{name: "Order", description: "Order description", quantity: "1", amount: 1900}]
  #  )
  #  redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
  end
 

  def review
    if params[:token].nil?
      redirect_to store_url, :notice => 'Woops! Something went wrong!'
      return
    end

    gateway_response = @gateway.details_for(params[:token])

    unless gateway_response.success?
      redirect_to store_url, :notice => 'Sorry! Something went wrong!'
      return
    end

    @order_info = get_order_info gateway_response, @cart
  end


  private
    def assigns_gateway

      @gateway ||= PaypalExpressGateway.new(
        :login => 'simon.king65-facilitator_api1.gmail.com',
        :password => 'MLP7C4HCMZTT6A7Y',
        :signature => 'AcbkD2jLSn.hCPB3rhfsE5wX8zSMAvxbibNzxPzROTihhXQOhWvagcfE'
      )
    end
end