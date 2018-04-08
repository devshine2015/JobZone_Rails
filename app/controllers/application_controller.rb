class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  # respond_to :json, if: Proc.new { |c| c.request.format == 'application/json' }
  respond_to :html, :json
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:phone, :role_id, :email])
    devise_parameter_sanitizer.permit(:sign_in) do |user_params|
      user_params.permit(:phone, :role_id, :email)
    end
  end
end
