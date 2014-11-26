class ApiController < ApplicationController
	before_filter :cors_set_access_control_headers, :only=>[:query_from_time_table, :query_from_cos_adm]
	def testttt

=begin
	OldCourseDetail.all.group(:course_teachership_id).each do |oldcd|
		newcd=CourseDetail.where(:semester_id=>oldcd.semester_id, :temp_cos_id=>oldcd.temp_cos_id).take
		if newcd
			NewOldCt.create(:old_ct_id=>oldcd.course_teachership_id, :new_ct_id=>newcd.course_teachership_id)
		end
	end
=end

	#NewOldCt.create
=begin		
		CourseFieldList.where("course_group_id IS NULL").each do |cfl|
			old_id=OldCourse.find(cfl.course_id).real_id
			new_id=Course.where(:real_id=>old_id).take.id
			cfl.course_id=new_id
			cfl.save!
		end
=end

=begin
		CourseGroupList.all.each do |cfl|
			old_id=OldCourse.find(cfl.course_id).real_id
			new_id=Course.where(:real_id=>old_id).take
			if new_id
			cfl.course_id=new_id.id
			cfl.save!
			else 
				cfl.destroy
			end
		end
=end

=begin

		@new_sem_ids=[0,1,2,4,5,7,8,10,11,13]
		TempCourseSimulation.includes(:old_course_detail).where("semester_id != 0").each do |cs|
			new_cd=CourseDetail.where(:temp_cos_id=>cs.old_course_detail.temp_cos_id, :semester_id=>cs.old_course_detail.semester_id).take
			if new_cd.nil?
				Rails.logger.debug "NOT FOUND cd_id:"+cs.old_course_detail.id.to_s
				cs.destroy
			else
				cs.course_detail_id=new_cd.id
				#cs.semester_id=@new_sem_ids[cs.semester_id]
				cs.save!
			end
			
		end


		TempCourseSimulation.includes(:old_course_detail).where("semester_id = 0 AND course_detail_id != 0").each do |cs|
			course=Course.where(:real_id=>cs.old_course.real_id).take
			new_cd_id=course.course_details.take.id
			#NewCourseDetail.where(:temp_cos_id=>cs.course_detail.temp_cos_id).take.id
			cs.course_detail_id=new_cd_id
			cs.save!
		end
=end

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
		#sendE3={:acy=>"99", :sem=>"3"}
		http=Curl.post("http://dcpc.nctu.edu.tw/plug/n/nctup/CourseList",sendE3)
		ret=JSON.parse(http.body_str.force_encoding("UTF-8"))
		res=[]

		ret.each do |data|
			#next if CourseDetail.where(:unique_id=>data['unique_id']).take
			#res.push(data)
			
			course_id=get_cid_by_real_id(data)
			#if data['teacher']!=""
			tids=[]
			NewTeacher.where(:real_id=>data['teacher'].split(',')).each do |t|
				
				tids.push(t.id)
			end
			nct=NewCourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
			#end
			save_cd(data,nct.id,sem.id)

		end

		return ret
	end
	def save_cd(data,ct_id,sem_id)
		return if NewCourseDetail.where(:temp_cos_id=>data["cos_id"], :semester_id=>sem_id).take
		@cd=NewCourseDetail.new
		@cd.course_teachership_id=ct_id
		@cd.semester_id=sem_id
		@cd.grade=data["grade"]
		costime=data['cos_time'].split(',')
		@cd.time=""
		@cd.room=""
		costime.each do |t|
			@cd.time<<t.partition('-')[0]
			@cd.room<<t.partition('-')[2]
		end
		
		#@cd.credit=data['cos_credit'].to_i

		@cd.cos_type=data["cos_type"]
		@cd.temp_cos_id=data["cos_id"]
		@cd.memo=data["memo"]
		@cd.students_limit=data["num_limit"]
		@cd.reg_num=data["reg_num"]
		
		@cd.brief=data["brief"]
		@cd.save!
		#return @cd
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
		course=NewCourse.where(:real_id=>data["cos_code"]).take
		if course.nil?
			course=NewCourse.new
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
