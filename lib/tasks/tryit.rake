# encoding: utf-8
## Testing rake
namespace :tryit do
  desc "zzz"
	task :zzz=> :environment do
		cf = CourseField.find(827)
		data=cf.course_field_lists.where(:course_id=>nil).order("updated_at DESC").includes(:course_group, :course_group_lists).each do |cfl|
			tmp={
			:cfl_id=>cfl.id,
			:cg_id=>cfl.course_group_id,
			:record_type=>cfl.record_type,
			:grade=> cfl.grade,
			:half=> cfl.half,
			:gtype=>cfl.course_group.gtype
			}
			puts cfl.course_group.to_json
			cfl.course_group.includes(:courses, :departments).course_group_lists.order("lead DESC").each do |cgl|
				tmpgg={
				:cgl_id=>cgl.id, 
				:course_id=>cgl.course.id ,
				:course_name=>cgl.course.ch_name,
				:dept_name=>cgl.course.dept_name,#try(:department).try(:ch_name),
				:real_id=>cgl.course.real_id,
				:credit=>cgl.course.credit
				}
			end
		end	
	end
  desc "test"
	task :test => :environment do 
	  p DataStatistics.import_course_count
	end

	desc "test2"
	task :test2 => :environment do 
	  CourseDetail.all.each(&:touch)
	end
	
	desc "test3"
	task :test3 => :environment do 
	  p Benchmark.measure { User.joins("LEFT JOIN auth_e3s ON users.id = auth_e3s.user_id")
						 .ransack(name_or_studentId_cont: "0256067").result }
	end
	
end

