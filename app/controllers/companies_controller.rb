class CompaniesController < InheritedResources::Base

  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :get_company, only: [:update_profile, :update_cover]

  def update_profile
    @company.profile.attach(io: image_io, filename: image_name)
    if @company.save
      render json: { success: true, message: "successfully uploaded!", profile_url: @company.profile_url}, status: 200
    else
      render json: { success: false, errors: @company.errors }, status: 422
    end
  end

  def update_cover
    @company.cover.attach(io: image_io, filename: image_name)
    if @company.save
      render json: { success: true, message: "successfully uploaded!", cover_url: @company.cover_url}, status: 200
    else
      render json: { success: false, errors: @company.errors }, status: 422
    end
  end

  private

  def get_company
    @company = Company.find(params[:company_id])
  end

  def image_io
    decoded_image = Base64.decode64(params[:company][:image])
    StringIO.new(decoded_image)
  end

  def image_name
    params[:company][:file_name]
  end

    def company_params
      params.require(:company).permit(:title, :description).merge(user_id: current_user.id)
    end
end

