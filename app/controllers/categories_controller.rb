class CategoriesController < InheritedResources::Base

  private

    def category_params
      params.require(:category).permit(:title, :industry_id)
    end
end

