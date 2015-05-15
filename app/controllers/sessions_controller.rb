class SessionsController < ApplicationController
=begin
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to "/user"
  end 
=end
	def sign_in
		render "/main/sign_in", :layout=>false
	end
	

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
	
	
  def destroy
    #session[:user_id] = nil
    session[:auth_e3] = nil
    session[:auth_fb] = nil
    sign_out current_user
    redirect_to root_url
  end
end