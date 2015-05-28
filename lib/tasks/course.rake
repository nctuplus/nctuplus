# encoding: utf-8

require "#{Rails.root}/app/helpers/api_helper"
include ApiHelper

namespace :course do
	desc "import course from e3"
	task :build => :environment do 
		Semester.all.each do |sem|
			datas=E3Service.get_course(sem)
			cds=CourseDetail.where(:semester_id=>sem.id)
			datas.each do |data|
				update_cd(data,cds,sem)
			end
			puts "Update #{sem.name} success!"
		end
	end
	
	task :update => :environment do
		COURSE_LOGGER.info "==========Starting update=========="
		update_department_list
		update_teacher_list
		sem=Semester.last
		datas=E3Service.get_course(sem) #get course
		COURSE_LOGGER.info "[Course Detail] #{datas.length} courses from E3 getted."		
		stat={"Create"=>0, "Update"=>0}		
		datas.each do |data|
			#course_id=get_cid_by_real_id(data)
			course_id=Course.get_from_e3(data)
			tids=[]
			Teacher.where(:real_id=>data['teacher'].split(',')).each do |t|
				tids.push(t.id)
			end
			nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
			stat[CourseDetail.save_from_e3(data,nct.id,sem.id)]+=1
		end
		data_cos_ids=datas.map{|data|data['cos_id']}
		old_cos_ids=CourseDetail.where(:semester_id=>sem.id).map{|data|data.temp_cos_id}
		diff_cos_ids=old_cos_ids-data_cos_ids		
		CourseDetail.where(:semester_id=>Semester.last.id, :temp_cos_id=>diff_cos_ids).destroy_all
		COURSE_LOGGER.info "[Course Detail] Deleted : #{diff_cos_ids.length}."		
		COURSE_LOGGER.info "[Course Detail] Created : #{stat["Create"]}."
		COURSE_LOGGER.info "[Course Detail] Updated : #{stat["Update"]}."		
		COURSE_LOGGER.info "==========Update Finished=========="
	end
	
	task :import_new => :environment do
		#create new semester
		new_sem=Semester.create_new
		new_sem.save!
		
		update_department_list
		update_teacher_list
		datas=E3Service.get_course(new_sem) #get course
		datas.each do |data|
			course_id=Course.get_from_e3(data)
			tids=[]
			Teacher.where(:real_id=>data['teacher'].split(',')).each do |t|
				tids.push(t.id)
			end
			nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
			#save_cd(data,nct.id,new_sem.id)
			CourseDetail.save_from_e3(data,nct.id,new_sem.id)
		end
		puts "#{datas.length} courses has imported !"
	end
	
end