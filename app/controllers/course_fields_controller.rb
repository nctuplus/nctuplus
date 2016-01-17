class CourseFieldsController < ApplicationController

	before_filter :require_xhr


private
	
	def require_xhr
		unless request.xhr?		
			render :nothing=>true
			return false
		end
	end

end