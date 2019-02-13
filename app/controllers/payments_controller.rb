class PaymentsController < ApplicationController
  before_action :authorize_user, only: [:create]
  swagger_controller :payments, "Payments"

  # POST /payments
  swagger_api :create do
    summary "Create payment"
    param :form, :user_id, :integer, :required, "User id"
    param_list :form, :payment_type, :string, :required, "Payment type", [:employee_list_week, :employee_list_month, :vacancies_4, :vacancies_5, :employee_search,
                                                                          :standard, :economy, :banner, :security_file]
    param :form, :price, :integer, :required, "Price"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unprocessable_entity
  end
  def create
    ActiveRecord::Base.transaction do
      price = Payment.get_price(params[:payment_type])
      unless price == params[:price]
        render status: :forbidden and return
      end

      if payment_type == 'employee_search'
        payments = @user.payments.where(
            payment_type: [Payment.payment_types['vacancies_5'], Payment.payment_types['vacancies_4']]
        )

        if payments.count == 0
          render status: :forbidden and return
        end
      end

      payment = Payment.new(
          user_id: params[:user_id],
          price: price,
          payment_type: payment_type
      )
      if payment.save

        @pay_desc = Hash.new
        @pay_desc['mrh_url'] = ENV['MERCHANT_URL']
        @pay_desc['mrh_login'] = ENV['MERCHANT_LOGIN']
        @pay_desc['mrh_pass1'] = ENV['MERCHANT_PASS_1']
        @pay_desc['inv_id'] = 0
        @pay_desc['out_summ'] = payment.price.to_s
        @pay_desc['shp_item'] = payment.id
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
        payment.destroy
        render json: payment.errors, status: :unprocessable_entity
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

      payment = Payment.where(:id => params['Shp_item']).first
      break if payment.blank?

      break if payment.price != params['OutSum'].to_f

      ActiveRecord.Base::transaction do
        payment.invid = params['InvId'].to_i
        payment.status = "ok"
        payment.expires_at = DateTime.now + Payment.calc_expiration(payment)
        payment.save

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
