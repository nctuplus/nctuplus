class CallbacksController < Devise::OmniauthCallbacksController

AUTH_E3 = 0
AUTH_GOOGLE = 1
AUTH_FACEBOOK = 2

    def facebook
    	# block user that has fb info and want to auth fb again
			if current_user and session[:auth_facebook] 
			  alertmesg("info",'warning', "您已登入") 
				redirect_to :root
				return
			end
			
      auth_record = AuthFacebook.from_omniauth(env["omniauth.auth"])
      result = _login_logic(auth_record, AUTH_FACEBOOK)
      alertmesg('info','warning', result[:msg]) 
      if result[:status]      
        _additional_session(result[:user])
				sign_in_and_redirect result[:user], :event => :authentication
      else
        if current_user.present?
          redirect_to :root
        else
          redirect_to :new_user_session
        end
      end
    end

    def google_oauth2
     
      if current_user and session[:auth_google] 
			  alertmesg("info",'warning', "您已登入") 
				redirect_to :root
				return
			end
      
      auth_record = AuthGoogle.from_omniauth(env["omniauth.auth"])
      result = _login_logic(auth_record, AUTH_GOOGLE)
      alertmesg('info','warning', result[:msg])
     	if result[:status]       
        _additional_session(result[:user])
				sign_in_and_redirect result[:user], :event => :authentication
      else
        if current_user.present?
          redirect_to :root
        else
          redirect_to :new_user_session
        end
      end
    end
    
    def E3
			if current_user # block all user who has logined
				alertmesg('info','warning', "您已登入") 
				redirect_to :root
				return
			end
      
			result = AuthE3.from_omniauth(params[:username], params[:password], current_user)
      alertmesg('info','warning', result[:msg]) 
			if result[:auth]
				_additional_session(result[:user])
				sign_in_and_redirect result[:user], :event => :authentication
			else			
				redirect_to :new_user_session
			end	
    end

private		
	  
# perform binding or login process, and return result with login user or error msg  
  def _login_logic(auth_record, auth_type)
    if current_user.present?
    # user tends to bind
      if _check_can_binding(auth_type) && _check_can_be_binded(auth_record)
      # process binding flow        
        if _bind_auth(auth_record)          
          return {:status=> true, :user=> current_user, :action=>"bind", :msg=> "綁定成功"}
        end         
      end
      # fail to bind
      return {:status=> false, :user=> nil, :action=>"bind", :msg=> "綁定失敗"}
    else
    # user tends to login
      user = _login_by_auth_record(auth_record)     
      return {:status=> true, :user=> user, :action=>"login", :msg=> "登入成功"}
    end 
  end
  
  def _check_can_binding(bind_target)
    return false if !current_user.hasE3?    
    case bind_target
      when AUTH_GOOGLE
        return !current_user.hasGoogle?
      when AUTH_FACEBOOK
        return !current_user.hasFb?
    end
    return false
  end
  
  def _check_can_be_binded(auth_record)
    if auth_record.user_id.nil?
      return true
    else
      return !auth_record.user.hasE3?
    end
  end
  
  # login to auth reocrd user. Check the existing of record user. If not, create a new user
  def _login_by_auth_record(record)
    if record.user_id.nil?
      new_user = User.create_from_auth({
            :name=>record.name,
            :email=>record.email || "#{Devise.friendly_token[0,7]}@auth.no.email"
          })
      record.update_attributes!(:user_id=> new_user.id)    
    end
    return record.user
  end
  
  # bind the auth record to current_user
  def _bind_auth(record)
    if !current_user.present?
      raise "[Fatal Error] current_user is not present when using binding method."
    end
    
    if record.user_id.present?   
      record.user.merge_child_to_newuser(current_user) # merge existed auth user to e3 user
    end
    record.update_attributes!(:user_id=>current_user.id)
        
    return true
  end
			
	def _additional_session(user)
		store_location_for(:user, session[:last_url])	#for devise usage, redirect to last page after sign in
		session[:auth_e3] = user.try(:auth_e3).try(:to_json)
		session[:auth_facebook] = user.try(:auth_facebook).try(:to_json)
    session[:auth_google] = user.try(:auth_google).try(:to_json)		
	end

end