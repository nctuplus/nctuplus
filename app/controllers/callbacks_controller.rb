class CallbacksController < Devise::OmniauthCallbacksController

    def facebook
    	# block user that has fb info and want to auth fb again
			if current_user and session[:auth_facebook] 
			  alertmesg("info",'warning', "您已登入") 
				redirect_to :root
				return
			end
			
      result = AuthFacebook.from_omniauth(env["omniauth.auth"], current_user)
      if not result[:auth]
        alertmesg('info','warning',result[:message])
			  redirect_to :root
        return 
      end

      _additional_session(result[:user])
      sign_in_and_redirect result[:user], :event => :authentication

    end

    def E3
			if current_user # block all user who has logined
				alertmesg('info','warning', "您已登入") 
				redirect_to :root
				return
			end
			result = AuthE3.from_omniauth(params[:username], params[:password], current_user)
			if result[:auth]
				_additional_session(result[:user])
				sign_in_and_redirect result[:user], :event => :authentication
			else
				alertmesg('info','warning', result[:message]) 
				redirect_to :new_user_session
			end	
    end

private		
			
			
	def _additional_session(user)
		store_location_for(:user, session[:last_url])	#for redirect back to last url
		session[:auth_e3] = user.try(:auth_e3).try(:to_json)
		session[:auth_facebook] = user.try(:auth_facebook).try(:to_json)		
	end

end