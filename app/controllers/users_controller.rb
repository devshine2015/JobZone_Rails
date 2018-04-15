class UsersController < ApplicationController
  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :check_verification, only: :verify

  def show
    respond_to do |format|
      format.html
      format.json { render json: current_user.as_json}
    end
  end

  def update
    if current_user.update(user_params)
      respond_to do |format|
        format.html { redirect_to request.referer || root_path  }
        format.json  { render json: current_user.as_json, status: 200 }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path(current_user) }
        format.json  {render json: { errors: current_user.errors}}
      end
    end
  end

  def update_language
    current_user.update_attribute(:local, params[:new_locale])
    respond_to do |format|
      format.html { redirect_to request.referer || root_path }
      format.json { render json: {success: true} }
    end
  end

  def verify
    if current_user.verification_code == params[:verification_code]
      current_user.is_verified = true
      current_user.verification_code = ''
      current_user.save
      render json: {success: true, message: "Succcessfully verified."}, status: 200
    else
      render json: {success: false, message: "Invalid verification code."}, status: 401
    end
  end

  private

  def check_verification
    render json: {success: false, message: "User already verified."},status: 201 if current_user.is_verified?
  end

  def user_params
    params[:user].permit(:email, :phone, :role_id, :local)
  end
end
