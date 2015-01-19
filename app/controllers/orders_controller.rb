class OrdersController < ApplicationController
  skip_before_action :authorize, only: [:new, :create, :execute, :cancel]
  include CurrentCart
  before_action :set_cart, only: [:new, :create, :ppcheckout]
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    if @cart.line_items.empty?
      redirect_to store_url, notice: "Your cart is empty"
      return
    end
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    logger.info "log info"
    @order = Order.new(order_params)
    @order.add_line_items_from_cart(@cart)
    @order.payment_method = @order.pay_type
  #@order.attributes = params[:order]
  
    @order.return_url = order_confirm_url(":order_id")
    @order.cancel_url = order_cancel_url(":order_id")
    #respond_to do |format|

    logger.info "just about to payment_method and save"
    logger.info @order.inspect
      if @order.payment_method
     
        if  @order.save
          
          logger.info "about to approve url"
          if @order.approve_url
            
            logger.info @order.approve_url.to_s
            redirect_to @order.approve_url
          else
            redirect_to store_url, :notice => "Order[#{@order.description}] placed successfully"
          end  
        
        else
          logger.info "failed to order.save"
          logger.info @order.error["message"]

        end

      else
        logger.info "failed!!!"
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    #end
  end


  def execute
    
    order = Order.find(params[:order_id])
    debugger  
    if order.execute(params["payer_id"], params["payment_id"])
              Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        OrderNotifier.received(order).deliver
        #format.html { redirect_to store_url, notice: 'Thank you for your order.' }
        #format.json { render :show, status: :created, location: @order }
      redirect_to store_url, :notice => "Order placed successfully"
    else
      redirect_to store_url, :alert => order.payment.error.inspect
    end
  end

  def confirm
    order = Order.find(params[:order_id])
    @order = order
    debugger
    #@payment = Payment.find(params["paymentId"])
    @payer_id = params["PayerID"]
    @payment_id = params["paymentId"]
      if order.confirm(params["PayerID"], params["paymentId"])
            #  Cart.destroy(session[:cart_id])
       # session[:cart_id] = nil
      #  OrderNotifier.received(order).deliver
        #format.html { redirect_to store_url, notice: 'Thank you for your order.' }
        #format.json { render :show, status: :created, location: @order }
      #redirect_to store_url, :notice => "Order[#{order.description}] placed successfully"
    else
      redirect_to store_url, :alert => order.payment.error.inspect
    end


  end

  def cancel
    order = current_user.orders.find(params[:order_id])
    unless order.state == "approved"
      order.state = "cancelled"
      order.save
    end
    redirect_to orders_path, :alert => "Order[#{order.description}] cancelled"
  end
  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def ppcheckout
    @order = Order.new
    @order.add_line_items_from_cart(@cart)
    @order.payment_method = "Paypal"
  #@order.attributes = params[:order]
  
    @order.return_url = order_confirm_url(":order_id")
    @order.cancel_url = order_cancel_url(":order_id")
    #respond_to do |format|

 #   logger.info "just about to payment_method and save"
    logger.info @order.inspect
    debugger
      if @order.payment_method
     debugger
        if  @order.save(validate: false)
          @order.update_column(:payment_method, "Paypal")
          logger.info "about to approve url"
          if @order.approve_url
            
            logger.info @order.approve_url.to_s
            redirect_to @order.approve_url
          else
            redirect_to store_url, :notice => "Order[#{@order.description}] placed successfully"
          end  
        
        else
          logger.info "failed to order.save"
          logger.info @order.error["message"]

        end

      else
        logger.info "failed!!!"
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end


  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:name, :address, :email, :pay_type, :payment_method)
    end
end
