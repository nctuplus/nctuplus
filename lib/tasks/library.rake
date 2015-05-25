# encoding: utf-8



namespace :library do

  desc "get set_no"
	task :test1 => :environment do 
	  Library.test("紅樓夢")
	end

  desc "search"
	task :test2 => :environment do 
    Library.search("")
	end

end