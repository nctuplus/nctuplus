# encoding: utf-8
## Testing rake
namespace :tryit do

  desc "test"
	task :test => :environment do 
	  p DataStatistics.import_course_count
	end

	desc "test2"
	task :test2 => :environment do 
	  CourseDetail.all.each(&:touch)
	end
end