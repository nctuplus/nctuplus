class CallbacksController < Devise::OmniauthCallbacksController

    def facebook
			
      result = AuthFacebook.from_omniauth(env["omniauth.auth"], current_user)
      if not result[:auth]
        alertmesg("info",'warning',result[:message])
			  redirect_to :root
        return 
      end
      _additional_session(result[:user])
      sign_in_and_redirect result[:user], :event => :authentication

    end

    def E3
        result = AuthE3.from_omniauth(params[:username], params[:password], current_user)
				if result[:auth]
					_additional_session(result[:user])
				  sign_in_and_redirect result[:user], :event => :authentication
				else
					alertmesg("info",'warning',auth[:message]) 
					redirect_to "/signin", :layout=>false
				end	
    end

private		
			
	def _additional_session(user)
		session[:auth_e3] = user.try(:auth_e3).try(:to_json)
		session[:auth_facebook] = user.try(:auth_facebook).try(:to_json)		
	end

end