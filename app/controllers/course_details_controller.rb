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
		else
			@q = Course.search({:id_eq=>0})	
		end
		
		@courses=@q.result(distinct: true).includes(:course_details).reject{|c|c.course_details.empty?}.sort_by{|c|c.course_details.first.cos_type}
		
		if params[:map_id].presence
			course_group = CourseGroup.where("gtype=0 AND course_map_id=? ",params[:map_id]).map{|cg| cg.id}
			course_group_courses = CourseGroupList.where(:course_group_id=>course_group, :lead=>0).includes(:course).map{|c| c.course}
			@courses = @courses.reject{|course| course_group_courses.include? course }
		end
		
	end
	def users
		
	end

end
