class SearchController < ApplicationController

	def course_teachership
		@q=CourseTeachership.search(params[:q])
		if request.format=="js"
			@res=@q.result(distinct: true).includes(:course).page(1).map{|cts|{
				:id=>cts.id,
				:course_name=>cts.course_ch_name,
				:teacher_name=>cts.teacher_name
			}}
		else
			@book=Book.find(params[:book_id])
			#@cts_list=@book.course_teachership
		end
	end
	
end
