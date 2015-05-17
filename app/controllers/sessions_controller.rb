class SessionsController < ApplicationController

=begin
	def get_courses
		result={
			:view_type=>"schedule",
			:use_type=>"add",
			:courses=>CourseDetail.where(:id=>session[:cd]).map{|cd|
				cd.to_search_result
			}
		}
		respond_to do |format|
			format.json {
				render json:result
			}
		end
	end
=end	

end