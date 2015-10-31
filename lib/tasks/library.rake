# encoding: utf-8
namespace :library do

  desc "test"
	task :test => :environment do 
	  p Library.test("9780262531962","ISBN")
	end

end