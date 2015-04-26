class ApiController < ApplicationController
	before_filter :cors_set_access_control_headers, :only=>[:query_from_time_table, :query_from_cos_adm]
	def testttt
		#current_user.agree_courses.create(:target_id=>555)
		#@x=current_user.agree_courses.first.course_detail.id
		#@x=current_user.agree_courses.first.course_detail.id
	end   
	def tempcs_change_to_new_sem_id
		TempCourseSimulation.includes(:course_detail).where("semester_id != 0").all.each do |tempcs|
			tempcs.semester_id=tempcs.course_detail.semester_id
			tempcs.save
		end
	end
	def change_to_newdept_id
		Course.includes(:department).all.each do |course|
			dept=course.department
			@new_dept=NewDepartment.where(:degree=>dept.degree.to_i, :dep_id=>dept.real_id).take
			new_dept_id=@new_dept ? @new_dept.id : 0
			course.department_id=new_dept_id
			course.save
		end
	end
	def save_new_dept_use_type
		Department.all.each do |dept|
			@new_dept=NewDepartment.where(:degree=>dept.degree.to_i, :dep_id=>dept.real_id).take
			if @new_dept
				@new_dept.use_type=dept.dept_type
				@new_dept.save!
			end
		end
	end


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
