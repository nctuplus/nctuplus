# encoding: utf-8

require "#{Rails.root}/app/helpers/api_helper"
include ApiHelper

namespace :course do
	desc "import course from e3"
	task :build => :environment do 
		Semester.all.each do |sem|
			datas=get_course_from_e3(sem)
			cds=CourseDetail.where(:semester_id=>sem.id)
			datas.each do |data|
				update_cd(data,cds,sem)
			end
			puts "Update #{sem.name} success!"
		end
	end
	task :import_new => :environment do
		#create new semester
		new_sem=Semester.create_new
		new_sem.save!
		updateDepartmentList
		updateTeacherList
		datas=get_course_from_e3(new_sem) #get course
		datas.each do |data|
			course_id=get_cid_by_real_id(data)
			tids=[]
			Teacher.where(:real_id=>data['teacher'].split(',')).each do |t|
				tids.push(t.id)
			end
			nct=CourseTeachership.find_or_create_by(:course_id=>course_id, :teacher_id=>tids.to_s)
			save_cd(data,nct.id,new_sem.id)
		end
		puts "#{datas.length} courses has imported !"
	end
	
end