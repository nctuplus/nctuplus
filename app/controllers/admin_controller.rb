class AdminController < ApplicationController
	def courses
    @courses=@department.courses
  end
	
end
