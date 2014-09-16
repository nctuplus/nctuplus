class CourseDetailsController < ApplicationController
	include CourseHelper
	layout false, :only=>[:mini, :course_group]
	def index
		@q = CourseDetail.search(params[:q])
		@cds=@q.result(distinct: true).includes(:course, :teacher, :semester).page(params[:page])
		@cd_all=get_mixed_info2(@cds)
  	end
	def mini
		if !params[:q].blank?
			@q = CourseDetail.search(params[:q])
			@q.sorts = 'cos_type asc' if @q.sorts.empty?
		else
			@q = CourseDetail.search({:id_in=>session[:cd].presence||0})
			
		end
		#@q = CourseDetail.search(params[:q])
		@cds=@q.result(distinct: true).includes(:course, :teacher, :semester)
		
		@cd_all=get_mixed_info2(@cds)
	end
	def course_group
		if !params[:q].blank?
			@q = Course.search(params[:q])
			@q.sorts = 'cos_type asc' if @q.sorts.empty?
		else
			@q = Course.search({:department_id_eq=>params[:dept_id]})	
		end
		#@q = CourseDetail.search(params[:q])
		@courses=@q.result(distinct: true).includes(:course_details)
		@cds=@courses.map{|c|c.course_details.first}
		
		@cd_all=get_mixed_info2(@cds)
	end

end
