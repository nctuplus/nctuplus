class CallbacksController < Devise::OmniauthCallbacksController

    def facebook
			return if _isLogin?
      user = AuthFacebook.from_omniauth(env["omniauth.auth"])
      session[:user_id] = user.id
      
      redirect_to :root
    end

    def E3
				return if _isLogin?
        user = AuthE3.from_omniauth(params[:username], params[:password])
				if user
					session[:user_id] = user.id
					redirect_to :root
				else
					alertmesg("info",'warning',"登入失敗") 
					redirect_to "/signin", :layout=>false
				end	
    end

private		
		
	def _isLogin?	
		if current_user.presence	
			alertmesg("info",'warning',"您已登入")
			redirect_to :root
			return true
		end	
	end	
end