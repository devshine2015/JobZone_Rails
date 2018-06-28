class CategoriesController < InheritedResources::Base

  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }

  after_action :create_candidate_searches, only: :index
  before_action :get_category, only: :categories_users

  def index
    @search = {key: params[:key]}
    @categories = Category.search(@search, params[:page])
    respond_to do |format|
      format.html { @categories || root_path }
      format.json {
        render json: @categories.as_json(
            include: [
                :industry=>{
                    only: [:id, :title],
                    methods: [:picture_url]
                }
            ]
        )
      }
    end
  end

  def categories_users
    if @category
      current_user.categories << @category unless current_user.categories.include?(@category)
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: {
            success: true,
            user_id: current_user.id,
            categories: current_user.categories.as_json
        }, status: 200 }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: { success: false, message: "Category not found!"}, status: 401 }
      end
    end
  end

  private

  def get_category
    @category = Category.where(id: params[:category_id]).first
  end

  def create_candidate_searches
    current_user.searches.create(@search) if @search[:key].present?
  end

  def category_params
    params.require(:category).permit(:title, :industry_id)
  end
end

