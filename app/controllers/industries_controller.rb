class IndustriesController < InheritedResources::Base

  private

    def industry_params
      params.require(:industry).permit(:title)
    end
end

