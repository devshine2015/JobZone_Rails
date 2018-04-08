class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :check_verification, only: :verify
  def verify
    if @user.verification_code == params[:verification_code]
      @user.is_verified = true
      @user.verification_code = ''
      @user.save
      render json: {success: true, message: "Succcessfully verified."}, status: 200
    else
      render json: {success: false, message: "Invalid verification code."},status: 401
    end
  end

  private

  def check_verification
    render json: {success: false, message: "User already verified."},status: 201 if @user.is_verified?
  end
end
