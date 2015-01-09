class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

	helper_method :latest_semester, :now_semester
  def latest_semester
		Semester.last
  end
	
	def now_semester
		Semester.find(13)
	end
  
  def record_not_found
		alertmesg("info",'Sorry',"無此欄位!")
    redirect_to action: :index
  end
	
	def ajax_flash(_class,title,mesg)

	end
	def getUserByIdForManager(uid)
		return checkTopManagerNoReDirect &&uid.presence&& uid!="" ? User.find(uid) : current_user
	end
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  def checkLogin
    unless current_user
			alertmesg("info",'Sorry',"請先登入,謝謝!")
			if request.env["HTTP_REFERER"].nil?
				redirect_to :root
			else
				redirect_to :back
			end
			return false
		end
		return true
  end
  
  def checkE3Login
  	msg = ''
  	flag = true
    if current_user.nil?
			msg, flag = '請先登入,謝謝' , false
		elsif current_user.student_id.blank?
			msg, flag = '請綁定e3,謝謝' , false
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
    if current_user.nil?
			msg, flag = '請先登入,謝謝' , false
		elsif current_user.uid.nil?
			msg, flag = '請綁定FB,謝謝' , false
		end
		if !flag	
			alertmesg("info",'Sorry',msg)
			redirect_back
			
		end 
		return flag
  end
  
  def checkCourseMapPermission
  	if current_user && (current_user.role==0 || current_user.role == 2)
  		return true
		end
		alertmesg("danger",'Sorry',"您沒有操作此動作的權限")  
  	redirect_to root_url
  end
  
  def checkTopManagerNoReDirect
		return current_user.role==0
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
    
  def checkDiscussOwner
		case params[:type]
			when "main"
				@discuss=Discuss.find(params[:discuss_id])
			when "sub"
				@discuss=SubDiscuss.find(params[:discuss_id])
			else
				redirect_to :back
		end
		
		if current_user != @discuss.user
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
		if current_user
			redirect_to :action=> "special_list", :controller=> "user"
		end
	end
	
private	
	def redirect_back
		if request.env["HTTP_REFERER"].nil?
				redirect_to :root
			else
				redirect_to :back
			end
	end
	
end
