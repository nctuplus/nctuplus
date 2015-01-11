class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    
    if current_user and not current_user.uid and current_user.student_id and user.student_id.blank? # 原本有登入(e3)，要綁fb
    
    	if !current_user.course_simulations.empty?
    		user.course_simulations.destroy_all
    		current_user.course_simulations.each do |cs|
    			cs.user_id = user.id
    			cs.save! 
    		end
    	end
			if !current_user.user_coursemapships.empty?
    		user.user_coursemapships.destroy_all
    		current_user.user_coursemapships.each do |cm|
    			cm.user_id = user.id
    			cm.save! 
    		end
    	end
			
			if !current_user.file_infos.empty?
    		current_user.file_infos.each do |file|
					file.user_id = user.id
    			file.save!
				end
    	end
			
    	user.student_id = current_user.student_id
			user.semester_id = current_user.semester_id if user.semester_id.nil?||user.semester_id==0
			user.department_id = current_user.department_id if user.department_id.nil?||user.department_id==0
			user.role = current_user.role
			user.agree = current_user.agree	
    	user.save!
			
    	current_user.destroy # delete e3 user
    	session[:user_id] = user.id	
    elsif not current_user
    	session[:user_id] = user.id
    else
    	alertmesg("info",'Sorry','綁定失敗')  			
    end	
    
    redirect_to "/user/special_list"
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