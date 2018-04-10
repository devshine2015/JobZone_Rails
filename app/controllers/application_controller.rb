class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :html, :json
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_locale # get locale directly from the user model

  def set_locale
    user_language = User::LANGUAGES.key(current_user.local)
    if user_language
      I18n.locale = user_signed_in? ? User::LANGUAGES.key(current_user.local).to_sym : I18n.default_locale
    else
      I18n.locale = I18n.default_locale
    end
  end
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:phone, :role_id, :email])
    devise_parameter_sanitizer.permit(:sign_in) do |user_params|
      user_params.permit(:phone, :role_id, :email)
    end
  end
end
