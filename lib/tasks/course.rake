# encoding: utf-8

namespace :course do
	desc "import course from e3"
	task :import => :environment do
		COURSE_LOGGER.info "==========Starting update=========="
		
		update_department_list
		update_teacher_list
		
		sem=Semester.last
		datas=E3Service.get_course(sem) #get course
		COURSE_LOGGER.info "[Course Detail] #{datas.length} courses from E3 getted."
		if datas.length == 0
			COURSE_LOGGER.info "No courses, stop updating"
		else
			stat={"Create"=>0, "Update"=>0}
			datas.each do |data|
				stat[do_update_coourse(data,sem)]+=1
			end
			data_cos_ids=datas.map{|data|data['cos_id']}
			old_cos_ids=CourseDetail.where(:semester_id=>sem.id).map{|data|data.temp_cos_id}
			diff_cos_ids=old_cos_ids-data_cos_ids		
			CourseDetail.where(:semester_id=>Semester.last.id, :temp_cos_id=>diff_cos_ids).destroy_all
			COURSE_LOGGER.info "[Course Detail] Deleted : #{diff_cos_ids.length}."		
			COURSE_LOGGER.info "[Course Detail] Created : #{stat["Create"]}."
			COURSE_LOGGER.info "[Course Detail] Updated : #{stat["Update"]}."		
		end
		COURSE_LOGGER.info "==========Update Finished=========="
	end
	
	task :create_new_sem => :environment do
		#create new semester
		new_sem=Semester.create_new
		new_sem.save!
		puts "#{new_sem.id} : #{new_sem.name} created."
	end

=begin
	task :import_new => :environment do
		#create new semester
		new_sem=Semester.create_new
		new_sem.save!
		
		update_department_list
		update_teacher_list
		datas=E3Service.get_course(new_sem) #get course
		datas.each do |data|
			do_update_coourse(data)
		end
		puts "#{datas.length} courses has imported !"
	end
=end
	
	def update_teacher_list
		COURSE_LOGGER.info "Updating Teacher..."
		teachers=E3Service.get_teacher_list	
		tids=teachers.map{|t|t["TeacherId"]}
		@deleted=Teacher.update_all({:is_deleted=>true},["real_id NOT IN (?)",tids])
		COURSE_LOGGER.info "[Teacher] Total #{@deleted}  Deleted."
		all_now=Teacher.all.map{|t|{"TeacherId"=>t.real_id, "Name"=>t.name}}
		@new=teachers - all_now
		@new.each do |t|
			@teacher=Teacher.create(
				:real_id=>t["TeacherId"],
				:name=>t["Name"],
				:is_deleted=>false
			)
			COURSE_LOGGER.info "[Teacher] - #{@teacher.name} Created."
		end
		COURSE_LOGGER.info "[Teacher] Total:#{@new.length} Created."
	end
	
	def update_department_list
		COURSE_LOGGER.info "Updating Department..."
		new_depts=E3Service.get_department_list
		Department.all.each do |dept|
			new_depts=new_depts.reject{|new_dept|new_dept["degree"].to_i==dept.degree&&new_dept["dep_id"]==dept.dep_id}
		end
		new_depts.each do |dept|
			@dept=Department.create_from_e3(dept)
			COURSE_LOGGER.info "[Department] - #{@dept.ch_name} Created."
		end
		COURSE_LOGGER.info "[Department] Total:#{new_depts.length} Created."
	end
	
	def do_update_coourse(data,sem)
		course_id=Course.get_from_e3(data).id
		tids=[]
		Teacher.where(:real_id=>data['teacher'].split(',')).each do |t|
			tids.push(t.id)
		end
		nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
		return CourseDetail.save_from_e3(data,nct.id,sem.id)
	end
	
end