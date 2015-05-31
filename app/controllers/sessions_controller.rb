class SessionsController < ApplicationController
	def save_lack_course
		session[:lack_course]={} if session[:lack_course].blank?
		request.request_parameters.keys.each do |key|
			session[:lack_course][key]=request.request_parameters[key]
		end
		respond_to do |format|
			format.json {
				render json: session[:lack_course]
			}
		end
		#render :nothing=>true, :status=>200
	end
	
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