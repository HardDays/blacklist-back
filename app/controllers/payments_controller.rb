class PaymentsController < ApplicationController
  before_action :authorize_user, only: [:create]
  swagger_controller :payments, "Payments"

  # POST /payments
  swagger_api :create do
    summary "Create payment"
    param :form, :user_id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unprocessable_entity
  end
  def create
    ActiveRecord::Base.transaction do
      subscription = Subscription.new(user_id: @user.id)

      if subscription.save
        payment = Payment.new(subscription_id: subscription.id, price: ENV['SUBSCRIPTION_PRICE'])

        if payment.save

          @pay_desc = Hash.new
          @pay_desc['mrh_url'] = ENV['MERCHANT_URL']
          @pay_desc['mrh_login'] = ENV['MERCHANT_LOGIN']
          @pay_desc['mrh_pass1'] = ENV['MERCHANT_PASS_1']
          @pay_desc['inv_id'] = 0
          @pay_desc['out_summ'] = payment.price.to_s
          @pay_desc['shp_item'] = subscription.id
          @pay_desc['in_curr'] = "WMRM"
          @pay_desc['culture'] = "ru"
          @pay_desc['encoding'] = "utf-8"


          @pay_desc['crc'] = Payment.get_hash(@pay_desc['mrh_login'],
                                              @pay_desc['out_summ'],
                                              @pay_desc['inv_id'],
                                              @pay_desc['mrh_pass1'],
                                              "Shp_item=#{@pay_desc['shp_item']}")
          render json: @pay_desc, status: :ok
        else
          render json: payment.errors, status: :unprocessable_entity
        end
      else
        render json: subscription.errors, status: :unprocessable_entity
      end
    end
  end

  def result
    crc = Payment.get_hash(params['OutSum'],
                           params['InvId'],
                           ENV['MERCHANT_PASS_2'],
                           "Shp_item=#{params['Shp_item']}")
    @result = "FAIL"

    begin
      break if params['SignatureValue'].blank? || crc.casecmp(params['SignatureValue']) != 0

      subscription = Subscription.where(:id => params['Shp_item']).first
      break if subscription.blank?

      payment = subscription.payments.where(status: "added").first
      break if payment.price != params['OutSum'].to_f

      ActiveRecord.Base::transaction do
        payment.invid = params['InvId'].to_i
        payment.status = "ok"
        payment.save
        subscription.last_payment_date = DateTime.now
        subscription.save

        @result = "OK#{params['InvId']}"
      end
    end while false

    render plain: @result, status: :ok
  end

  private
    def authorize_user
      @user = AuthorizationHelper.auth_user(request, params[:user_id])

      if @user == nil
        render status: :forbidden and return
      end
    end
end
