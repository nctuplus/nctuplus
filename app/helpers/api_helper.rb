module ApiHelper
	def get_course_from_e3(sem)
		sendE3={:acy=>sem.year, :sem=>sem.half}
		#sendE3={:acy=>"99", :sem=>"3"}
		http=Curl.post("http://dcpc.nctu.edu.tw/plug/n/nctup/CourseList",sendE3)
		ret=JSON.parse(http.body_str.force_encoding("UTF-8"))
		return ret
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
			#end
			save_cd(data,nct.id,sem.id)
			
		else
=begin
			costime=data['cos_time'].split(',')
			@cd.time=""
			@cd.room=""
			costime.each do |t|
				@cd.time<<t.partition('-')[0]
				@cd.room<<t.partition('-')[2]
			end
			@cd.department_id=get_deptid(data["degree"].to_i,data["dep_id"])
			@cd.save!
=end		
			#puts "Update success,id=#{@cd.id}\n"
		end	
	end
	
	def save_cd(data,ct_id,sem_id)
		return if CourseDetail.where(:temp_cos_id=>data["cos_id"], :semester_id=>sem_id).take
		@cd=CourseDetail.new
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
	
	
	def get_deptid(degree,dep_id)
		return 0 if dep_id==""
		dept=Department.where(:degree=>degree, :dep_id=>dep_id).take
		return dept ? dept.id : 0
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
				student_id=s2[2]
				dept=s2[0]
				student_name=s2[4]
			elsif s2.length>5 && s2[0].match(/[[:digit:]]/)
				#Rails.logger.debug "[debug] "+s2[1]
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					#Rails.logger.debug "[debug] "+s2[1]
					agree.append({:real_id=>s2[1], :credit=>s2[3].to_i, :memo=>s2[5], :name=>s2[2], :cos_type=>s2[4]||""})
				elsif s2[1].include?('.')
					course=course
				elsif s2[1].match(/[[:digit:]]{3}+/) && s2[2].match(/[[:digit:]]{4}/)
					course={'sem'=>s2[1], 'cos_id'=>s2[2], 'score'=>s2[7], 'name'=>s2[4], 'cos_type'=>s2[5]||""}
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
