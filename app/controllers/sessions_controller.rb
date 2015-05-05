class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
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