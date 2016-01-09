# encoding: utf-8

namespace :course do
	desc "import course from e3"
	task :import => :environment do
		inform_mesg=""
		inform_mesg << updateDepartmentList
		inform_mesg << updateTeacherList
		
		Semester.last(2).each do |sem|			
			datas=E3Service.getCourse(sem) #get course
			inform_mesg << "[Course Detail] Got : #{datas.length} courses from E3.<br>"
			if datas.length == 0
				inform_mesg << "No courses, stop updating.<br>"
			else
				stat={"Create"=>0, "Update"=>0}				
				data_cos_ids=datas.map{|data|data['cos_id']}
				old_cos_ids=CourseDetail.where(:semester_id=>sem.id).map{|data|data.temp_cos_id}
				diff_cos_ids=old_cos_ids-data_cos_ids
				CourseDetail.where(:semester_id=>sem.id, :temp_cos_id=>diff_cos_ids).destroy_all
				inform_mesg << "[Course Detail] Deleted : #{diff_cos_ids.length}.<br>"
				datas.each do |data|
					stat[doUpdateCourse(data,sem)]+=1
				end
				inform_mesg << "[Course Detail] Created : #{stat["Create"]}.<br>"
				inform_mesg << "[Course Detail] Updated : #{stat["Update"]}.<br>"		
			end
		end
		InformMailer.course_import(inform_mesg).deliver
	end
	
	task :create_new_sem => :environment do
		#create new semester
		new_sem=Semester.create_new
		new_sem.save!
		puts "#{new_sem.id} : #{new_sem.name} created."
	end

	
	def updateTeacherList
		inform_mesg=""
		inform_mesg << "Updating Teacher...<br>"
		teachers=E3Service.getTeacherList	
		inform_mesg << "[Teacher] Get #{teachers.length} from E3.<br>"
		tids=teachers.map{|t|t["TeacherId"]}
		@deleted=Teacher.update_all({:is_deleted=>true},["real_id NOT IN (?)",tids])
		inform_mesg << "[Teacher] Total : #{@deleted}  Deleted.<br>"
		all_now=Teacher.all.map{|t|{"TeacherId"=>t.real_id, "Name"=>t.name}}
		@new=teachers - all_now
		@new.each do |t|
			@teacher=Teacher.create(
				:real_id=>t["TeacherId"],
				:name=>t["Name"],
				:is_deleted=>false
			)
			inform_mesg << "[Teacher] - #{@teacher.name} Created.<br>"
		end
		inform_mesg << "[Teacher] Total : #{@new.length} Created.<br><br>"
		return inform_mesg
	end
	
	def updateDepartmentList
		inform_mesg=""
		inform_mesg << "Updating Department...<br>"
		new_depts=E3Service.getDepartmentList
		inform_mesg << "[Department] Get #{new_depts.length} from E3.<br>"
		Department.all.each do |dept|
			if !dept.course_details.empty?
				dept.has_courses=true
				dept.save
			end
			new_depts=new_depts.reject{|new_dept|new_dept["degree"].to_i==dept.degree&&new_dept["dep_id"]==dept.dep_id}
		end
		new_depts.each do |dept|
			@dept=Department.create_from_e3(dept)
			inform_mesg << "[Department] - #{@dept.ch_name} Created.<br>"
		end
		inform_mesg << "[Department] Total : #{new_depts.length} Created.<br><br>"
		return inform_mesg
	end
	
	def doUpdateCourse(data,sem)
		course_id=Course.get_from_e3(data).id
		tids=[]
		Teacher.where(:real_id=>data['teacher'].split(',')).each do |t|
			tids.push(t.id)
		end
		nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
		return CourseDetail.save_from_e3(data,nct.id,sem.id)
	end
	
end
