class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
	before_filter :redirect_if_old
  protect_from_forgery with: :exception
  protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

	helper_method :current_user


	def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
	
  def record_not_found
		alertmesg("info",'Sorry',"無此欄位!")
		if !request.xhr?
			redirect_to action: :index
		end
  end
	
	def getUserByIdForManager(uid)
		return ( (uid.present? and checkTopManagerNoReDirect) ? User.find(uid) : current_user )
	end
  
  def checkDepYear
    if user_signed_in?
      if current_user.department_id.nil? or current_user.department_id==0
        alertmesg("info",'Sorry',"請先填寫系級")
        redirect_to user_edit_path
      else
        return true
      end
    else
      return true 
    end
  end
  
  def checkLogin
    unless user_signed_in?
			alertmesg("info",'Sorry',"請先登入,謝謝!")
			redirect_back
			return false
		end
		return true
  end
  
  def checkE3Login
  	msg = ''
  	flag = true
    if not user_signed_in?
			msg, flag = '請先登入,謝謝' , false
		elsif session[:auth_e3].nil?
			msg, flag = '必須由E3登入才可使用' , false
		end
		if !flag	
			alertmesg("info",'Sorry',msg)
			redirect_back
		end 
		return flag
  end
  
  def checkFBLogin
    msg = ''
  	flag = true
    if not user_signed_in?
			msg, flag = '請先登入,謝謝' , false
		elsif session[:auth_facebook].nil?
			msg, flag = '必須由facebook登入才可使用' , false
		end
		if !flag	
			alertmesg("info",'Sorry',msg)
			redirect_back
		end 
		return flag
  end
  
  def checkCourseMapPermission
  	if user_signed_in? && (current_user.role==0 || current_user.role == 2)
  		return true
		end
		alertmesg("danger",'Sorry',"您沒有操作此動作的權限")  
  	redirect_to root_url
  end
  
  def checkTopManagerNoReDirect
		if user_signed_in? and current_user.role==0
			true
		else 
			false
		end
  end
  
  def checkTopManager
    if checkLogin
			if current_user.role==0
				return true
			else
				alertmesg("danger",'Sorry',"您沒有操作此動作的權限")    
				redirect_to root_url
			end	  	
		end
  end
 

	def checkOwner
		case params[:controller]
			when "discusses"
				case params[:type]
					when "main"
						target=Discuss.find(params[:id])
					when "sub"
						target=SubDiscuss.find(params[:id])
					else
						redirect_to :back
				end
			when "events"
				target=Event.find(params[:id])
			when "past_exams"
				target=PastExam.find(params[:id])
		end
		if current_user != target.user
			alertmesg("danger",'Sorry',"您沒有操作此動作的權限")
			redirect_to :back
		end
	end
  
  def alertmesg(type,title,msg)
    flash[:notice] = {
			:style => "alert-"<<type,
			:title => title,
			:message => msg
		  }
  end
	
	def redirect_to_user_index
		if user_signed_in?
			redirect_to :action=> "special_list", :controller=> "user"
		end
	end
	
private	
	def redirect_back
		#if !request.xhr?
		session[:last_url]=request.original_url
		#end
		redirect_to "/login"

	end
		
	def redirect_if_old
    if request.host == 'nctuplus.nctucs.net'
      redirect_to "#{request.protocol}plus.nctu.edu.tw:#{request.port}#{request.fullpath}", :status => :moved_permanently 
    end
  end
	
end
