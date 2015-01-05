class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    
    if current_user and not current_user.uid and current_user.student_id and user.student_id.nil? # 原本有登入(e3)，要綁fb
    
    	if not current_user.course_simulations.empty?
    		user.course_simulations.destroy_all
    		current_user.course_simulations.each do |cs|
    			cs.user_id = user.id
    			cs.save! 
    		end
    	end
    	user.student_id = current_user.student_id
    	user.save!
    	current_user.destroy
    	session[:user_id] = user.id	
    elsif not current_user
    	session[:user_id] = user.id
    else
    	alertmesg("info",'Sorry','綁定失敗')  			
    end	
    
    redirect_to root_url
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
    session[:user_id] = nil
    redirect_to root_url
  end
end