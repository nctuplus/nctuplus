class UserController < ApplicationController
	require 'net/http'
  require "net/https"
	include CourseHelper
	
  before_filter :checkTopManager, :only=>[:manage, :permission]
	before_filter :checkLogin, :only=>[:add_course, :import_course, :special_list, :select_dept]
  layout false, :only => [:add_course]
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
	def add_top_manager
		
		if TopManager.find_or_create_by_user_id(:user_id=>params[:uid].to_i, :all_users=>1, :all_departments=>1)
			mesg="新增成功!"
		else
			mesg="新增失敗"
		end
		respond_to do |format|
			format.html {
				render :text => mesg,
							 :content_type => 'text/html',
							 :layout => false
			}
		end
	end
	def special_list
		ls=latest_semester

		@cs_agree=current_user.course_simulations.includes(:course_detail,:course,:teacher).where(:semester_id=> 0)#, :course, :teacher)
		@cs_all=current_user.course_simulations.includes(:course_detail,:course,:teacher).where("semester_id != 0")#, :course, :teacher)
		
		@cs_all_cos_type=@cs_all.sort_by{|cs|cs.course_detail.cos_type}
		@cs_all_sem=@cs_all.sort_by{|cs|cs.course_detail.semester_id}
		@cs_this=@cs_all.select{|cs|cs.semester_id==ls.id}
		@pass_score=current_user.department&&current_user.department.degree=='2' ? 70 : 60
		@cs_all_passed=@cs_all.select{|cs|cs.score=="通過"||cs.score.to_i>=@pass_score}+ @cs_agree
	
		cs_all_scored=@cs_all.reject{|cs|cs.score=="通過"||cs.score=="不通過"||cs.semester_id==latest_semester.id}
		gpa_all = 0.0
		all_credit = 0.0
		cs_all_scored.each do |cs|
			point=calc_gpa_point(cs.score.to_i)
			credit=cs.course_detail.credit.to_i
			gpa_all+=credit * point
			all_credit+=credit
	  end
		@gpa_all= gpa_all #/ all_credit

		#fb_url = "#{current_user.uid}/notifications?access_token=272520269546220|9dd6af5c70d6eac3d26e656e4b638fa3&href=/user/special_list&template=213123123"
  #uri = URI.encode("https://graph.facebook.com/#{fb_url}")
  #uri = URI.parse(uri)
  #http = Net::HTTP.new(uri.host, uri.port)
  #http.use_ssl = true
  #http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  #fb_req = Net::HTTP::Post.new(uri.request_uri)
  #fb_response = http.request(fb_req)
		
	end
	
	
	def add_course
		score=params[:course][:score]
		@score=score
		@agree=[]
		@normal=[]
		@score.split("\n").each do |s|
			s2=s.split("\t") 
			if s2.length>5 &&s2[0].match(/[[:digit:]]/)
				#Rails.logger.debug "[debug] "+s2[1]
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					#Rails.logger.debug "[debug] "+s2[1]
					@agree.append({:real_id=>s2[1], :credit=>s2[3].to_i})
				elsif s2[1].include?('.')
					course=course
				elsif s2[1].match(/[[:digit:]]{3}+/)&&s2[2].match(/[[:digit:]]{4}/)
				course={'sem'=>s2[1],'cos_id'=>s2[2], 'score'=>s2[7], 'name'=>s2[4]}
				@normal.append(course)
				
				end	
			end 
		end
		@course=[]
		pass_score=current_user.department.degree=='2' ? 70 : 60
		@has_added=0
		@success_added=0
		@fail_added=0
		@fail_course_name=[]
		@no_pass=0
		@pass=0
		if @normal.length>0
			CourseSimulation.where("user_id = ? AND semester_id != ? ",current_user.id,Semester.last.id).destroy_all
		end

		@agree.each do |a|
			#Rails.logger.debug "[debug] "+Course.where(:real_id=>a).take.ch_name
			
			course=Course.includes(:course_details).where(:real_id=>a[:real_id]).take
			unless course.nil?
			cd_temp=course.course_details.where(:credit=>a[:credit]).first
			CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cd_temp.id, :semester_id=>0, :score=>"通過")
			end
		end

		@normal.each do |n|
			#dept_id=Department.select(:id).where(:ch_name=>n['dept_name']).take
			if n['score']=="通過" || n['score'].to_i>=pass_score
				@pass+=1
			else
				@no_pass+=1
			end
			sem=n['sem']
			@sem=Semester.where(:year=>sem[0..sem.length-2], :half=>sem[sem.length-1]).take
			if @sem
				cds=CourseDetail.where(:semester_id=>@sem.id, :temp_cos_id=>n['cos_id']).take
				if cds	
					CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cds.id, :semester_id=>cds.semester_id, :score=>n['score'])
					@success_added+=1
				else
					#@fail_course_name.append()
					@fail_added+=1
				end
			else
				@fail_added+=1
			end
		end
		#respond_to do |format|
		#	format.html { redirect_to "user/special_list", :notice => "Successfully created place" }
		#	format.js

		#end
		redirect_to :action =>"special_list", :import_course=>true, :success=>@success_added, :pass=>@pass, :failed=>@fail_added, :no_pass=>@no_pass, :show_static=>true
	end
	
	
	def select_dept
		degree=params[:degree_select].to_i
		grade=params[:grade_select].to_i
		if degree==2
			dept=params[:dept_grad_select].to_i
		else
			dept=params[:dept_under_select].to_i
		end
		current_user.update_attributes(:semester_id=>grade,:department_id=>dept)
		redirect_to :controller=> "user", :action=>"special_list"
	end
  def manage
    @users=User.includes(:semester, :department).all
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
  private
  def calc_gpa_point(score)
	case score
		when 90..100
			point=4.3
		when 85..89
			point=4.0
		when 80..84
			point=3.7
		when 77..79
			point=3.3
		when 73..76
			point=3.0
		when 70..72
			point=2.7
		when 67..69
			point=2.3
		when 63..66
			point=2.0
		when 60..62
			point=1.7
		when 50..59
			point=1
		else
			point = 0
	end
	return point
  end
  def user_params
    params.require(:user).permit(:email)
  end
  
end
