module ApiHelper
	
	def updateTeacherList
		
		teachers=E3Service.get_teacher_list
		
		tids=teachers.map{|t|t["TeacherId"]}
		@deleted=Teacher.update_all({:is_deleted=>true},["real_id NOT IN (?)",tids])
		puts "#{@deleted} Teacher deleted"
		all_now=Teacher.all.map{|t|{"TeacherId"=>t.real_id, "Name"=>t.name}}
		@new=teachers - all_now
		@new.each do |t|
			@teacher=Teacher.new
			@teacher.real_id=t["TeacherId"]
			@teacher.name=t["Name"]
			@teacher.is_deleted=false
			puts "Teacher #{@teacher.name} created"
			@teacher.save!
		end
		puts "#{@new.length} teachers created"
	end
	
	def updateDepartmentList
		
		new_depts=E3Service.get_department_list
		
		#new_dept_ids=new_depts.map{|dept|dept["degree"]+dept["dep_id"]}
		#zzz=new_depts
		Department.all.each do |dept|
			new_depts=new_depts.reject{|new_dept|new_dept["degree"].to_i==dept.degree&&new_dept["dep_id"]==dept.dep_id}
		end
		#puts new_depts	
		new_depts.each do |dept|
			@dept=Department.new
			@dept.dep_id=dept["dep_id"]
			@dept.degree=dept["degree"].to_i
			@dept.dept_type=dept["depType"]
			@dept.ch_name=dept["dep_cname"]
			@dept.eng_name=dept["dep_ename"]
			@dept.use_type="dept"
			@dept.save!
			puts "Department #{@dept.ch_name} created"
		end
		puts "#{new_depts.length} departments created"
	end
	
	
	
	def update_cd(data,cds,sem)
		#@cd=CourseDetail.where(:temp_cos_id=>data["cos_id"], :semester_id=>sem_id).take
		@cd=cds.select{|cd|cd.temp_cos_id==data["cos_id"]}.first
		if @cd.nil?
			puts "CourseDetail not found,sem_id=#{sem.id}&cos_id=#{data["cos_id"]}\n"
			course_id=get_cid_by_real_id(data)
			#if data['teacher']!=""
			tids=[]
			Teacher.where(:real_id=>data['teacher'].split(',')).each do |t|
				tids.push(t.id)
			end
			nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
			save_cd(data,nct.id,sem.id)
		else
		end	
	end
	
	def save_cd(data,ct_id,sem_id)
		@cd=CourseDetail.where(:temp_cos_id=>data["cos_id"], :semester_id=>sem_id).take
		if @cd.nil?
			@cd=CourseDetail.new 
			ret="Create"
		else
			ret="Update"
		end
		@cd.course_teachership_id=ct_id
		@cd.department_id=get_deptid(data["degree"].to_i,data["dep_id"])
		@cd.semester_id=sem_id
		@cd.grade=data["grade"]
		costime=data['cos_time'].split(',')
		@cd.time=""
		@cd.room=""
		costime.each do |t|
			_time=t.partition('-')
			@cd.time<<_time[0]
			@cd.room<<_time[2]
		end
		@cd.cos_type=data["cos_type"]
		@cd.temp_cos_id=data["cos_id"]
		@cd.memo=data["memo"]
		@cd.students_limit=data["num_limit"]
		@cd.reg_num=data["reg_num"]
		

		@cd.brief=data["brief"]
		@cd.save!
		return ret
	end
	

	
	def get_cid_by_real_id(data)
		course=Course.where(:real_id=>data["cos_code"]).take
		if course.nil?
			course=Course.new
			course.real_id=data["cos_code"]
			course.ch_name=data["cos_cname"]
			course.eng_name=data["cos_ename"]
			course.credit=data["cos_credit"].to_i
			#course.department_id=get_deptid(data["degree"].to_i,data["dep_id"])
			course.save!
		end
		return course.id
	end
	
	
	def get_deptid(degree,dep_id)
		return 0 if dep_id==""
		dept=Department.where(:degree=>degree, :dep_id=>dep_id).take
		return dept.nil? ? 0 : dept.id 
	end
	
	def parse_scores(score)
		agree=[]
		normal=[]
		student_id=0
		student_name="" 
		dept=""
		score.split("\r\n").each do |s|
			s2=s.split("\t")
			if s2.length>3 && s2[2].match(/[[:digit:]]{5}+/)
				student_id=s2[2].delete(' ') #delete is for FF
				dept=s2[0]
				student_name=s2[4]
			elsif s2.length>5 && s2[0].match(/[[:digit:]]/)
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					agree.append({:real_id=>s2[1], :credit=>s2[3].to_i, :memo=>s2[5], :name=>s2[2], :cos_type=>s2[4]||""})
				elsif s2[1].match(/[[:digit:]]{3}+/) && s2[2].match(/[[:digit:]]{4}/)
					course={
						'sem'=>s2[1],
						'cos_id'=>s2[2],
						'score'=>s2[7].delete(' '), #delete is for FF
						'name'=>s2[4],
						'cos_type'=>s2[5]||""
					}
					normal.append(course)
				end	
			end 
		end
		return {
			:student_id=>student_id,
			:student_name=>student_name,
			:agreed=>agree,
			:taked=>normal,
			:dept=>dept
		}
	end
end
