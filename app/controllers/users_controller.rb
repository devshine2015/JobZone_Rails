class UsersController < ApplicationController
  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :check_verification, only: :verify
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
    unless User::LANGUAGES.key?(params[:new_locale].to_s.to_sym)
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

  def rsend_verification_code
    current_user.skip_password_validation = true
    current_user.rsend_verification_code!
    if current_user.save
      render json: {success: true, message: "Verification code sent on your phone!"}, status: 200
    else
      render json: { errors: current_user.errors}
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

  private

  def check_verification
    render json: {success: false, message: "User already verified."},status: 201 if current_user.is_verified?
  end

  def user_params
    params.require(:user).permit(:email, :phone, :role_id, :city, skills_attributes: [:id, :name, :_destroy])
  end

  def image_io
    decoded_image = Base64.decode64(params[:image][:content])
    StringIO.new(decoded_image)
  end

  def image_name
    params[:image][:file_name]
  end

  # def user_params
  #   params[:user].permit(:email, :phone, :role_id, :city, skills_attributes: [:id, :name, :years])
  # end
end
