class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :html, :json
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_locale, if: Proc.new { |c| c.request.format != 'application/json' }

  def authenticate_api_user!
    id = params[:user_id] || params[:id]
    @current_user = User.where(id: id, authentication_token: request.headers['HTTP_AUTHENTICATION_TOKEN']).first
    I18n.locale = (@current_user .local || I18n.default_locale) if @current_user
    render json: {success: false, message: "User not found! invalid ID or Authentication Token"}, status: 401 unless @current_user
  end

  def set_locale
      I18n.locale = (current_user.local || I18n.default_locale) if user_signed_in?
  end
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:phone, :role_id, :email])
    devise_parameter_sanitizer.permit(:sign_in) do |user_params|
      user_params.permit(:phone, :role_id, :email, :password)
    end
  end
end
