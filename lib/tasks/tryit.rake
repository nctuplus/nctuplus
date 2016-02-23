# encoding: utf-8
## Testing rake
namespace :tryit do
  desc "zzz"
	task :zzz=> :environment do
		puts `ls`
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

