module ApiHelper
	

	
	
	
	def update_cd(data,cds,sem)		
		@cd=cds.select{|cd|cd.temp_cos_id==data["cos_id"]}.first
		if @cd.nil?
			puts "CourseDetail not found,sem_id=#{sem.id}&cos_id=#{data["cos_id"]}\n"
			#course_id=get_cid_by_real_id(data)
			course_id=Course.get_from_e3(data).id
			tids=Teacher.where(:real_id=>data['teacher'].split(',')).map{|t|t.id}
			nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
			#save_cd(data,nct.id,sem.id)
			CourseDetail.save_from_e3(data,ct_id,sem_id)
		end
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
				student_id=s2[2].delete(' ') #for Firefox
				dept=s2[0]
				student_name=s2[4]
			elsif s2.length>5 && s2[0].match(/[[:digit:]]/)
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					agree.append({
						:real_id=>s2[1],
						:credit=>s2[3].to_i,
						:memo=>s2[5],
						:ch_name=>s2[2],
						:cos_type=>s2[4]||""
					})
				elsif s2[1].match(/[[:digit:]]{3}+/) && s2[2].match(/[[:digit:]]{4}/)
					course={
						'sem'=>s2[1],
						'cos_id'=>s2[2],
						'score'=>s2[7].delete(' '), #for Firefox
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
