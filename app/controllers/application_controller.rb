class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def record_not_found
    redirect_to action: :index
  end
	
	def ajax_flash(_class,title,mesg)
		html='<div id="ajax_notice" class="alert alert-'<<_class<<'" style="width:500px;position:fixed;left:300;top:100;z-index:2000;">'
		html<<'<h4>'<<title<<'</h4>'
		html<<mesg
		html<<'<div>'
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
	elsif current_user.student_id.nil?
	  msg, flag = '請綁定e3,謝謝' , false
	end
	
	if not flag	
	  alertmesg("info",'Sorry',msg)
	  if request.env["HTTP_REFERER"].nil?
			redirect_to :root
	  else
			redirect_to :back
	  end
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
	
	if not flag	
	  alertmesg("info",'Sorry',msg)
	  if request.env["HTTP_REFERER"].nil?
			redirect_to :root
	  else
			redirect_to :back
	  end
	 end 
	 
	 return flag
  end
  
  def checkCourseMapPermission
  	if current_user and (current_user.role==0 or current_user.role == 2)
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
		end	  	
    end   
	redirect_to root_url
  end
  
  def checkCourseManager #(course_id)
    
    if checkLogin
	  @departments=CourseManager.where(:user_id=>current_user.id)
	  if @departments
	    @departments.each do |department|
		  
		  department.courses.each do |course|
		    return true if course.id==params[:id]#course_id
		  end
		end
	  end
	  alertmesg("danger",'Sorry',"您沒有操作此動作的權限") 
		  redirect_to root_url
    end
    
  end
  
  def checkOwner
    case params[:controller] 
      when 'post'
				if Post.find(params[:id]).owner_id!=current_user.id
					alertmesg("danger",'Sorry',"您沒有操作此動作的權限")     
					redirect_to root_url
				#else return true
			end
			when 'files'
				@file=FileInfo.find_by_id(params[:id])
				if @file && @file.owner_id!=current_user.id
					alertmesg("danger",'Sorry',"您沒有操作此動作的權限")
				redirect_to root_url
				#else return true
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
	
	def save_my_previous_url
    # session[:previous_url] is a Rails built-in variable to save last url.
    session[:my_previouse_url] = URI(request.referer).path
  end

	def redirect_to_user_index
		if current_user
			redirect_to :action=> "special_list", :controller=> "user"
		end
	end
	
end
