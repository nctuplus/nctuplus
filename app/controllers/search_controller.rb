class SearchController < ApplicationController

	def cts	#course_teachership
		@q=CourseTeachership.search(params[:q])
		@cts=@q.result(distinct: true).page(params[:page]).per(25)
		render :layout=>false
	end
	
end
