class ApiController < ApplicationController
	before_filter :cors_set_access_control_headers, :only=>[:query_from_time_table, :query_from_cos_adm]
	def testttt
		@all=[]
		Semester.where("id NOT IN (?)",[1,3]).each do |sem|
		
			@all.push(save_course(sem))
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
	def clone_new_teacher_to_teacher
		NewTeacher.all.each do |nt|
			@teacher=Teacher.where(:name=>nt.name, :real_id=>nil).take
			if @teacher
				@teacher.real_id=nt.real_id
				@teacher.is_deleted=false
				@teacher.save!
			else
				Teacher.create(:real_id=>nt.real_id, :name=>nt.name, :is_deleted=>false)
			end
		end
	end
	def get_depts
		http=Curl.post("http://dcpc.nctu.edu.tw/plug/n/nctup/DepartmentList",{})
		@all=JSON.parse(http.body_str.force_encoding("UTF-8"))
		@all.each do |dept|
			@dept=NewDepartment.new
			@dept.dep_id=dept["dep_id"]
			@dept.degree=dept["degree"].to_i
			@dept.dept_type=dept["depType"]
			@dept.ch_name=dept["dep_cname"]
			@dept.eng_name=dept["dep_ename"]
			@dept.save!
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
	
	def create_sems
		h_name=["上","下","暑"]
		h_id=[1,2,3]
		(99..103).each do |year|
			(0..2).each do |index|
				NewSemester.create(:name=>year.to_s+h_name[index], :year=>year, :half=>h_id[index])
			end
		end
		
	end
	
	def save_course(sem)
		
		sendE3={:acy=>sem.year, :sem=>sem.half}
		#@sendE3={:acy=>"99", :sem=>"3"}
		http=Curl.post("http://dcpc.nctu.edu.tw/plug/n/nctup/CourseList",sendE3)
		ret=JSON.parse(http.body_str.force_encoding("UTF-8"))
		res=[]
		ret.each do |data|
			next if CourseDetail.where(:unique_id=>data['unique_id']).take
			res.push(data)
			course_id=get_cid_by_real_id(data)
			teacher_id=get_tid_by_id(data["teacher"])
			#ct_id=get_ctid(course_id,teacher_id)
			save_cd(data,course_id,teacher_id,sem.id)
		end
		return res
	end
	def save_cd(data,course_id,teacher_id,sem_id)
		@cd=CourseDetail.new(:unique_id=>data["unique_id"])
		#@cd=get_cd_by_id()
		#@cd.course_teachership_id=ct_id
		@cd.course_id=course_id
		@cd.teacher_id=teacher_id
		@cd.semester_id=sem_id
		@cd.grade=data["grade"]
		costime=data['cos_time'].split(',')
		@cd.time=""
		@cd.room=""
		costime.each do |t|
			@cd.time<<t.partition('-')[0]
			@cd.room<<t.partition('-')[2]
		end
		
		@cd.credit=data['cos_credit'].to_i

		@cd.cos_type=data["cos_type"]
		@cd.temp_cos_id=data["cos_id"]
		@cd.memo=data["memo"]
		@cd.students_limit=data["num_limit"]
		@cd.reg_num=data["reg_num"]
		
		@cd.brief=data["brief"]
		@cd.save!
	end
	def get_cd_by_id(unique_id)
		#return NewCourseDetail.find_or_create_by(:unique_id=>unique_id)
		return 
	end
	def get_deptid(degree,dep_id)
		return 0 if dep_id==""
		dept=Department.where(:degree=>degree, :dep_id=>dep_id).take
		return dept ? dept.id : 0
	end
	def get_ctid(cid,tid)
		return 0 if cid==0 || tid==0
		ct=NewCourseTeachership.find_or_create_by(:course_id=>cid, :teacher_id=>tid)
		return ct.id
	end
	def get_tid_by_id(teacher_id)
		return 0 if teacher_id==""
		teacher=Teacher.where(:real_id=>teacher_id).take
		tid=teacher.nil? ? 0 :teacher.id 
		return tid
	end
	def get_cid_by_real_id(data)
		course=Course.where(:real_id=>data["cos_code"]).take
		if course.nil?
			course=Course.new
			course.real_id=data["cos_code"]
			course.ch_name=data["cos_cname"]
			course.eng_name=data["cos_ename"]
			course.credit=data["cos_credit"].to_i
			course.department_id=get_deptid(data["degree"].to_i,data["dep_id"])
			course.save!
		end
		return course.id
	end
	def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Max-Age'] = "1728000"
    headers['Access-Control-Allow-Headers'] = 'content-type, accept'
  end
	
	
end
