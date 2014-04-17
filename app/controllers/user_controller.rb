class UserController < ApplicationController
 require 'digest/sha1'

  def mail_confirm
    @user=User.where(:activate_token=>params[:key]).first
	if(@user)
	  case @user.activated
	    when 2
		  @user.activated=3
		  @user.save
		  @message = "認證成功!您可以開始上傳/下載檔案囉!"
		when 3
	      @message = "您已經認證過囉!"
	    else
		  @message = "認證失敗!"
	  end
	else
	  @message= "沒有此使用者喔!"
	end
	
    flash[:notice] = @message
	redirect_to root_url
  end
  def activate
    
	@user=User.find(params[:id])
	if(@user.activated==1)
      UserMailer.confirm(@user.name,@user.email,@user.activate_token).deliver
	  @user.activated=2
	  @user.save
	end
    redirect_to "user/manage"
    
  end
  def manage
    @users=User.all
	
  end
  def registry
    
    @user=User.new
	render :layout => false
  end
  def create
	if request.post?
	  _email=params[:user][:email]
	  if User.where(:email=>_email).empty?
	    @user=current_user
		@user.email=_email
		@user.activate_token=Digest::SHA1.hexdigest @user.uid
		#@user.name="N/A"
		#@user.facebook_id=-1
		@user.grade_id=5
		@user.activated=0
		@user.save!
		@message="新增成功! 管理員將在之後寄出認證信!"
	  else
	    
		#@user.name="zzz"
		#@user.save!
		@message="Oops!您的Email已經有人使用囉!"<<current_user.name
	  end
	  flash[:notice] = @message	
	end
	
	#render nil
	#redirect_to :contoller=>:main, :action => :index

	#respond_to do |format|
	#	format.html {"123"}
	#end
	redirect_to root_url
	#render :nothing => true, :status => 200, :content_type => 'text/html'
  end
  
  private
  def user_params
    params.require(:user).permit(:email)
  end
  
end
