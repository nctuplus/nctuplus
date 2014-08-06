class UserController < ApplicationController
 require 'digest/sha1'
  before_filter :checkTopManager, :only=>[:manage, :permission]
  
  # def mail_confirm
    # @user=User.where(:activate_token=>params[:key]).first
		# if(@user)
			# case @user.activated
				# when 2
				# @user.activated=3
				# @user.save
				# @message = "認證成功!您可以開始上傳/下載檔案囉!"
			# when 3
					# @message = "您已經認證過囉!"
				# else
				# @message = "認證失敗!"
			# end
		# else
			# @message= "沒有此使用者喔!"
		# end
    # flash[:notice] = @message
		# redirect_to root_url
  # end
	
  # def activate
    
	# @user=User.find(params[:id])
	# if(@user.activated==1)
      # UserMailer.confirm(@user.name,@user.email,@user.activate_token).deliver
	  # @user.activated=2
	  # @user.save
	# end
    # redirect_to "user/manage"
    
  # end
	def select_dept
		degree=params[:degree_select].to_i
		if degree==2
			grade=params[:grade_grad_select].to_i
			dept=params[:dept_grad_select].to_i
		else
			grade=params[:grade_under_select].to_i
			dept=params[:dept_under_select].to_i
		end
		current_user.update_attributes(:grade_id=>grade,:department_id=>dept)
		redirect_to :controller=> "courses", :action=>"special_list"
	end
  def manage
    @users=User.all
  end
  
  def permission
    @user=User.find_by(params[:id])
		@departments=Department.all
    if request.post?
	  CourseManager.destroy_all(:user_id=>@user.id)
	  if params[:department]
	    params[:department][:checked].each do |key,value|
	      @course_manager=CourseManager.new(:user_id=>@user.id)
		  @course_manager.department_id=key
		  @course_manager.save!
	    end
	  end
	end
	
    
	
  end
  
  def registry
    
    @user=User.new
	render :layout => false
  end

	
  # def create
		# if request.post?
			# _email=params[:user][:email]
			# if User.where(:email=>_email).empty?
				# @user=current_user
			# @user.email=_email
			# @user.activate_token=Digest::SHA1.hexdigest @user.uid
			# @user.grade_id=5
			# @user.activated=0
			# @user.save!
			# @message="新增成功! 管理員將在之後寄出認證信!"
			# else
			# @message="Oops!您的Email已經有人使用囉!"<<current_user.name
			# end
			# flash[:notice] = @message	
		# end
	# redirect_to root_url
  # end
  
  private
  def user_params
    params.require(:user).permit(:email)
  end
  
end
