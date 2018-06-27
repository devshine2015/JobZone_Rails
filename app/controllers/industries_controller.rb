class IndustriesController < InheritedResources::Base
  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  after_action :create_candidate_searches, only: :index

  def index
    @search = {key: params[:key]}
    @industries = Industry.search(@search, params[:page])
    respond_to do |format|
      format.html { @industries || root_path }
      format.json { render json: @industries.as_json }
    end
  end
  private

    def create_candidate_searches
      current_user.searches.create(@search) if @search[:key].present?
    end

    def industry_params
      params.require(:industry).permit(:title)
    end
end

