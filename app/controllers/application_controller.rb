class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def checkOwner
    case params[:controller] 
      when 'post'
		if Post.find(params[:id]).owner_id!=current_user.id
		  flash[:notice] = {
			:style => "alert-danger",
			:title => "Sorry!",
			:message => "您沒有操作此動作的權限 "
		  }        
		  redirect_to root_url
		end
	  when 'files'
	    @file=FileInfo.find_by_id(params[:id])
	    if @file && @file.owner_id!=current_user.id
		  flash[:notice] = {
			:style => "alert-danger",
			:title => "Sorry!",
			:message => "您沒有操作此動作的權限 "
		  }
		  redirect_to root_url
		end	  
    end
  end 
end
