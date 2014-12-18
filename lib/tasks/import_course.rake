# encoding: utf-8

require "#{Rails.root}/app/helpers/api_helper"
include ApiHelper

namespace :import_course do
	desc "import course from e3"
	task :build => :environment do 
		Semester.all.each do |sem|
			datas=get_course_from_e3(sem)
			cds=CourseDetail.where(:semester_id=>sem.id)
			datas.each do |data|
				update_cd(data,cds,sem)
			end
		end
	end
	
	
end