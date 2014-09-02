class ApiController < ApplicationController
	before_filter :cors_set_access_control_headers, :only=>[:query_from_time_table, :query_from_cos_adm]
	def query_from_time_table
		#@user = Cour.take
		@cts=CourseTeachership.search({:course_real_id_in=>params[:cos_id], :teacher_name_in=>params[:teacher_name]})
		@cts=@cts.result(distinct: true).includes(:course, :teacher)
		#@courses=Course.where(:real_id=>params[:cos_id])
		#@teachers=Teacher.where(:name=>params[:teacher_name])
		respond_to do |format|
      format.html do
        render :json => @cts.map{|ct| {:c_id=>ct.course_id, :t_id=>ct.teacher_id, :real_id=>ct.course.real_id, :t_name=>ct.teacher.name}}#, :callback => params[:callback]
      end
    end
	end
	
	def query_from_cos_adm
		#@user = Cour.take
		sem=params[:sem_id]
		sem_id=Semester.where(:year=>sem[0..sem.length-2], :half=>sem[sem.length-1]).take.id
		@cds=CourseDetail.search({:temp_cos_id_in=>params[:cos_id], :semester_id_eq=>sem_id})
		@cds=@cds.result(distinct: true).includes(:course, :teacher)
		#@courses=Course.where(:real_id=>params[:cos_id])
		#@teachers=Teacher.where(:name=>params[:teacher_name])
		respond_to do |format|
      format.html do
        render :json => @cds.map{|cd| {:c_id=>cd.course.id, :t_id=>cd.teacher.id, :temp_cos_id=>cd.temp_cos_id}}#, :callback => params[:callback]
      end
    end
	end
	
	private
	def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Max-Age'] = "1728000"
    headers['Access-Control-Allow-Headers'] = 'content-type, accept'
  end
	
	
end
