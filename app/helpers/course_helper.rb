module CourseHelper
	def get_mixed_info2(cds)
		#courses=Course.join(:course_teachership).where(:id=>cds.map{|cd|cd.course_teachership})
		return [] if cds.empty?
		depts=Department.where(:id=>cds.map{|cd|cd.course.department_id}.uniq)
		dept_dulp=cds.map{|cd| depts.select{|d|d.id==cd.course.department_id}.first}
		return cds.zip(dept_dulp)
	end
	def get_mixed_info(cds)
		#courses=Course.join(:course_teachership).where(:id=>cds.map{|cd|cd.course_teachership})
		return [] if cds.empty?
		courses=Course.where(:id=>cds.map{|cd|cd.course_teachership.course_id})
		courses_dulp=cds.map{|cd| courses.select{|c|c.id==cd.course_teachership.course_id}.first}
		teachers=Teacher.where(:id=>cds.map{|cd|cd.course_teachership.teacher_id})
		teachers_dulp=cds.map{|cd| teachers.select{|t|t.id==cd.course_teachership.teacher_id}.first}
		return cds.zip(courses_dulp,teachers_dulp)
	end
	
	
	def get_autocomplete_vars
		@departments=Department.where("dept_type != 'no_courses'")#.merge(Department.where(:dept_type=>'common'))
		@departments_all_select=@departments.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_grad_select=@departments.select{|d|d.degree=='2'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_under_grad_select=@departments.select{|d|d.degree=='3'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_common_select=@departments.select{|d|d.degree=='0'||d.degree=="5"}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@degree_select=[{"walue"=>'3', "label"=>"大學部[U]"},{"walue"=>'2', "label"=>"研究所[G]"},{"walue"=>'0', "label"=>"大學部共同課程[C]"}].to_json
	end
	def join_course_detail(courses,semester_id)
		course_ids=courses.map{|c| c.id}
		ct_ids=CourseTeachership.select(:id).where(:course_id=>course_ids).pluck(:id)#@courses.map{|c|c.course_teacherships.map{|ct| ct.id}}
		if semester_id!=0
			course_details=CourseDetail.includes(:course_teachership, :semester).where(:course_teachership_id=>ct_ids, :semester_id=>semester_id).references(:course_teachership).order(:time)
		else
			course_details=CourseDetail.includes(:course_teachership, :semester).where(:course_teachership_id=>ct_ids).references(:course_teachership).order("semester_id DESC")
		end
		return course_details
	end
	
	def get_dept_ids(dept_id)
	  return nil if dept_id==0
		
	  dept_ids=[]
		@dept_main=Department.where(:id=>dept_id).take
		dept_ids.append(@dept_main.id)
		if @dept_main.dept_type=="dept"
			dept_college=Department.where(:degree => @dept_main.degree, :college_id=>@dept_main.college_id, :dept_type => 'college').take
			dept_ids.append(dept_college.id) if !dept_college.nil?
		end
		return dept_ids
	end
	
	def join_dept(course,dept_ids)
		dept_ids.each do |dept_id|
		  return true if course.department_id==dept_id
		end
		return false
	end
	
	def has_rated(ctr_id,ectr_arr)
		return current_user && ectr_arr.include?(ctr_id)
	end
	
	def latest_semester
		return Semester.last
	end
	def rollcall_name(id)
		str = ""
		case id
			when 1 #
				str = "每堂必點"
			when 2 #
				str = "經常抽點"
			when 3 #
				str= "偶爾抽點"
			when 4 #
				str = "不點名"
		end	
		return str.html_safe
	end	
	
	def rollcall_color(id)
		str = ""
		case id
			when 1 #
				str = "danger"
			when 2 #
				str = "warning"
			when 3 #
				str= "primary"
			when 4 #
				str = "success"
		end	
	end
	
	def content_type_to_html(id)
		str = ""
		case id
			when 1 #考試
				str = "[考試]"
			when 2 #作業
				str = "[作業]"
			when 3 #上課
				str= "[上課]"
			when 4 #其他
				str = "[其他]"
		end	
		return str.html_safe
	end
	
	def rankTag(rank)
		case rank.to_i 
			when 1
				return "#FFDB58"
			when 2 
				return "#808080"
			when 3
				return "#CD7F32"
			else
				return "black"
		end
			
	end
	
	def rankTagBar(rank)
		if rank>=1 and rank<=2
			return "success"
		elsif rank>=3 and rank<=4
			return "info"
		else
			return "default"
		end	
	end		

	def dimension_color(cos_type)
		case cos_type
			when "通識"
				'#FF91FE'
			when "歷史"
				'#FFC991'
			when "群已"
				'#C7FF91'
			when "公民"
				'#91FFC9'
			when "自然"
				'#91C7FF'
			when "文化"
				'#C991FF'
		end
	end
	
	def dimension_class(cos_type)
		prefix='dimension-'
		case cos_type
			when "通識"
				prefix<<'world'
			when "歷史"
				prefix<<'history'
			when "群已"
				prefix<<'youandme'
			when "公民"
				prefix<<'civil'
			when "自然"
				prefix<<'nature'
			when "文化"
				prefix<<'culture'
		end
	end
	
	def cos_type_class(cos_type)
		prefix="course-"
		case cos_type
			when "共同必修"
				type="common-required"
			when "共同選修"
				type="common-elective"
			when "通識"
				type='general'
			when "必修"
				type='required'
			when "選修"
				type='elective'
			when "外語"
				type='foreign'
			
		end
		#type=""
		prefix<<type
	end
	
	
	
	
end
