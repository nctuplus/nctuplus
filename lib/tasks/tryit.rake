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

end
