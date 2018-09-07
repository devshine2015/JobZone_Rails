class UsersController < ApplicationController
  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :validate_verification!, except: [:verify, :send_verification_code]
  before_action :validate_email!, only: :update
  before_action :check_verification, only: [:verify, :send_verification_code]
  # I added
  
  # before_action :create_skils, only: [:update]

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

  def conversations
    @conversations = current_user.candidate_conversations.page(params[:page]).order('created_at DESC') if current_user.has_role? User::ROLES[:employee]
    @conversations = current_user.employer_conversations.page(params[:page]).order('created_at DESC') if current_user.has_role? User::ROLES[:employer]
    respond_to do |format|
      format.html { @conversations || root_path }
      format.json { render json: @conversations.as_json }
    end
  end

  def update_language
    unless User::LANGUAGES.include?(params[:new_locale].to_s)
      message = "Invalid language!"
      respond_to do |format|
        format.html {
          flash[:alert] = message
          redirect_to request.referer || root_path
        }
        format.json { render json: {success: false, message: message}, status: 401 }
      end
    else
      current_user.update_attribute(:local, params[:new_locale])
      respond_to do |format|
        format.html { redirect_to request.referer || root_path }
        format.json { render json: {success: true} }
      end
    end
  end

  def verify
    if current_user.verification_code == params[:verification_code]
      current_user.is_verified = true
      current_user.verification_code = ''
      current_user.skip_password_validation = true
      if current_user.save
        render json: {success: true, message: "Succcessfully verified."}, status: 200
      else
        render json: { errors: current_user.errors}
      end
    else
      render json: {success: false, message: "Invalid verification code."}, status: 401
    end
  end

  def send_verification_code
    current_user.skip_password_validation = true
    current_user.send_user_verification_code!
    if current_user.save
      render json: {
          success: true,
          message: "Verification code sent on your phone!",
          id: current_user.id,
          phone: current_user.phone,
          authentication_token: current_user.authentication_token
      }, status: 200
    else
      render json: { errors: current_user.errors }
    end
  end

  def deactivate
    if current_user.update_attribute(:is_verified, false)
      render json: {success: true, message: "Succcessfully deactivated."}, status: 200
    else
      format.json  {render json: { errors: current_user.errors}}
    end
  end

  def update_profile
    current_user.profile.attach(io: image_io, filename: image_name)
    if current_user.save
      render json: { success: true, message: "successfully uploaded!", profile_url: current_user.profile_url}, status: 200
    else
      render json: { success: false, errors: current_user.errors }, status: 422
    end
  end

  def update_cover
    current_user.cover.attach(io: image_io, filename: image_name)
    if current_user.save
      render json: { success: true, message: "successfully uploaded!", cover_url: current_user.cover_url}, status: 200
    else
      render json: { success: false, errors: current_user.errors }, status: 422
    end
  end

  def update_settings
    if @current_user.update(setting_params)
      @current_user
    else
      render json: { success: false, errors: @current_user.errors }, status: 422
    end
  end

  def categories_users
    current_user.categories
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: {
          success: true,
          user_id: current_user.id,
          categories: current_user.categories.as_json
      }, status: 200 }
    end
  end

  def categories_industries

    # Update categories preferences
    categories = Category.where(id: params[:category_ids])
    current_user.categories.delete_all
    current_user.industries.delete_all
    delete_categories = Category.where.not(id: params[:category_ids])
    categories.each do |category|
      current_user.categories << category unless current_user.categories.include?(category)
    end

    #Update industry preferences
    industries = Industry.where(id: params[:industry_ids])
    industries.each do |industry|
      current_user.industries << industry unless current_user.industries.include?(industry)
    end
    render json: {
        categories: current_user.categories.as_json,
        industries: current_user.industries.as_json
    }, status: 200
  end

  private

  def check_verification
    render json: {success: false, message: "User already verified."},status: 201 if current_user.is_verified?
  end

  def validate_verification!
    render json: {success: false, message: "Your account is not verified!"},status: 201 unless current_user.is_verified?
  end

  def validate_email!
    unless user_params[:email].present?
      message = "Email can't be blank!"
      respond_to do |format|
        format.html {
          flash[:error] = message
          redirect_to request.referer || root_path
        }
        format.json { render json: {success: false, messsage: message }, status: 422 }
      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :role_id, :password, :password_confirmation)
  end

  def setting_params
    params.require(:user).permit(:local, preferred_job_address_attributes: [:id, :city, :country, :lat, :lng, :receive_notification])
  end

  def image_io
    decoded_image = Base64.decode64(params[:image][:content])
    StringIO.new(decoded_image)
  end

  def image_name
    params[:image][:file_name]
  end
end
