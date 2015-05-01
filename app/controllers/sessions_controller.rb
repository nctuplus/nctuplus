class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
=begin		
    if User.where(env["omniauth.auth"].slice(:provider, :uid)).empty?
			alertmesg("info",'Sorry','第一次使用請先登入E3帳號<br>綁定FB之後便可使用FB登入'.html_safe)
			redirect_to root_url
			return
			#
		else
=end		
    if current_user and not current_user.uid and current_user.student_id and user.student_id.blank? # 原本有登入(e3)，要綁fb
			#current_user.update_omniauth(env["omniauth.auth"])

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
			
			current_user.new_course_teacher_ratings.each do |ctr|
				ctr.user_id = user.id
				ctr.save!
			end
    	current_user.course_content_lists.each do |ctr|
				ctr.user_id = user.id
				ctr.save!
			end
			current_user.comments.each do |ctr|
				ctr.user_id = user.id
				ctr.save!
			end
			current_user.content_list_ranks.each do |ctr|
				ctr.user_id = user.id
				ctr.save!
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
		
    #end
		
    redirect_to "/user"
  end 

	def sign_in
		if current_user
			redirect_to :root 
		else	
			if request.post?
				data = E3Service.login(params[:username], params[:password])
				if data[:e3_auth]
					if data[:user]
						session[:user_id] = data[:user].id
					else
						new_user = User.create(
							:student_id=>params[:username],
							:name=>params[:username]
						)	
						session[:user_id] = new_user.id
					end
					redirect_to :root
				else
					alertmesg("info",'warning',"登入失敗") 
					render "/main/sign_in", :layout=>false
				end	
			else
				render "/main/sign_in",  :layout=>false	
			end	
		end	
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