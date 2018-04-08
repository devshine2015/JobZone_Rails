class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session
  respond_to :json

  def authenticate_user!
    @user = User.where(id: params[:user_id], authentication_token: params[:authentication_token]).first
    render json: {success: false, message: "User not found! invalid ID or Authentication Token"}, status: 401 unless @user
  end
end
