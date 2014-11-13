class PaypalExpressController < ApplicationController
  include CurrentCart
  before_filter :assigns_gateway, :set_cart

 
  include ActiveMerchant::Billing
  include PaypalExpressHelper
 
  def checkout

    total_as_cents, setup_purchase_params = get_setup_purchase_params @cart, request
    setup_response = @gateway.setup_purchase(total_as_cents, setup_purchase_params)
    debugger
    redirect_to @gateway.redirect_url_for(setup_response.token)
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