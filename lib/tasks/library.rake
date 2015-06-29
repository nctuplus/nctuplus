# encoding: utf-8



namespace :library do

  desc "test"
	task :test => :environment do 
	  set_no = Library.test("9780262531962","ISBN")
	end

  

end