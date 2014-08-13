class CourseDetailsController < ApplicationController
	include CourseHelper
	def index
		if !params[:q].blank?
			@q = CourseDetail.search(params[:q])
		else
			@q = CourseDetail.search({:id_lt=>50})
		end
		#@q = CourseDetail.search(params[:q])
		@cds=@q.result(distinct: true).includes(:course, :teacher, :semester).page(params[:page])
		
		@cd_all=get_mixed_info2(@cds)
  end
end
