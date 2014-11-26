class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
	include CourseHelper
  
	layout false, :only => [:course_raider, :list_all_courses, :search_by_keyword, :search_by_dept, :get_user_simulated, :get_user_courses, :get_sem_form, :get_user_statics, :show_cart, :get_compare]

	before_filter :checkLogin, :only=>[ :raider_list_like, :rate_cts]
	before_filter :checkE3Login, :only=>[:simulation, :add_simulated_course, :del_simu_course]
	

### for course_teacher_page_content	

	#def get_list_opt
	
	#end

	def course_raider
#		Rails.logger.debug "[debug] "+(params[:ct_id].presence|| "nil")
		ct = CourseTeachership.find(params[:ct_id])
		@ct_id = ct.id		
			if params[:type].to_i==1
				@page = CourseContentHead.where(:course_teachership_id => params[:ct_id].to_i).first.presence || nil			
				render "course_content_head"
			elsif params[:type].to_i==2
				@list = CourseContentList.where(:course_teachership_id => params[:ct_id].to_i)
				render "course_content_list"
			elsif params[:type].to_i==3  #3  -> head form
				@head = CourseContentHead.where(:course_teachership_id => params[:ct_id].to_i).first.presence ||
						CourseContentHead.new(:exam_record=>0, :homework_record=>0)	
				render "content_head_form"
			elsif params[:type].to_i==4	#4 -> list form
				@list = CourseContentList.where(:course_teachership_id => params[:ct_id].to_i).presence || nil		
				render "content_list_form"
			else # 5 -> chart			
				c_id = ct.course_id
				
				sems=Course.includes(:semesters).find(c_id).semesters.order(:id).uniq.last(5).reject{|s|s==latest_semester}	
			
				@row_name = sems.map{|s|s.name}				
				@row_id = sems.map{|s| s.id}
				if @row_id.length ==5
					@row_id.shift
					@row_name.shift
				end
				@tmp = Course.find(c_id).course_details.where(:semester_id=>@row_id).order(:semester_id)
				
				@simu = CourseSimulation.where(:semester_id=>@row_id, :course_detail_id=>@tmp.map{|ctd| ctd.id})  
		
				@res = []
				@res_score = []
				@res_score_drill=[]
				@show_flag = 0
				@tmp.map{|ctd| {:teacher=>ctd.teacher_name, :cdid=>ctd.id, :num=>ctd.reg_num, :sem=>ctd.semester_id } }
				.group_by{|t| t[:teacher]}.each do |k1, k2|
					@tmp_num = [0,0,0,0]
					@tmp_score = [{:y=>0,:nums=>1},{:y=>0,:nums=>1},{:y=>0,:nums=>1},{:y=>0,:nums=>1}]
					#@tmp_score2 = [1,2,3,4]
					zz=0
					k2.each do |hash|
						@tmp_num[@row_id.index(hash[:sem])] = hash[:num].to_i
						
						score_sum = 0 
						score_count = 0
						@simu.select{|sim| sim.semester_id==hash[:sem]&&sim.course_detail_id==hash[:cdid]}.each do |s|
							if s.score.presence and numeric?(s.score) #and s.score.to_i >=60
								score_sum+= s.score.to_i
								score_count+=1
								@show_flag = 1
							end
						end
					#	Rails.logger.debug "[debug] "+@row_name.to_s
						@tmp_score[@row_id.index(hash[:sem])][:y] = (score_count==0) ? 0 : score_sum/score_count*1.0
						@tmp_score[@row_id.index(hash[:sem])][:nums] = score_count
					end
					@res.push({:name=>k1, :data=>@tmp_num})
					@res_score.push({:name=>k1, :data=>@tmp_score})

				end
#				Rails.logger.debug "[debug] "+@res.to_s
				
				render "course_chart"
			end
	end
	
	def course_content_post

		if params[:post_type].to_i==0 #head
			@head = CourseContentHead.where(:course_teachership_id=> params[:ct_id]).first.presence ||
					 CourseContentHead.new(:course_teachership_id=> params[:ct_id])
			@head.last_user_id = current_user.id
			@head.exam_record = params[:test].to_i
			@head.homework_record = params[:hw].to_i
			@head.course_rollcall = params[:rollcall].to_i
			@head.save!

			render "content_head_update"
		else #list
			tr_id = params[:id][17..-1].to_i
			if params[:id].include?("new") #new

				@list = CourseContentList.new(:course_teachership_id=>params[:ct_id],:user_id=>current_user.id)
				@list.content_type = params[:content_type].to_i
				@list.content = params[:content]
				@list.save!
			else #update old
 				@list = CourseContentList.find(tr_id)
 				if params[:del].to_i==1
 					@list.destroy
 				else	
 					@list.content_type = params[:content_type].to_i
					@list.content = params[:content]
					@list.save!
					if @list.content_list_ranks.presence
						@list.content_list_ranks.destroy_all
					end	
				end
			end
			@trid = params[:id]
			render "content_list_update"
		end
	end
	
	def raider_list_like
		if ContentListRank.where(:user_id=>current_user.id, :course_content_list_id=>params[:list_id]).first.presence
			render :nothing => true, :status => 200, :content_type => 'text/html' #已給過評
		else
			@like = ContentListRank.new(:user_id=>current_user.id, :course_content_list_id=>params[:list_id],:rank=>params[:like_type])	
			if @like.save
				render "raider_list_like"
			else
				render :nothing => true, :status => 200, :content_type => 'text/html'
			end				
		end	
	end
	
	
	def comment_submit
		@com = Comment.new(:content=>params[:comment], :content_type=>params[:type].to_i)
		@com.user_id = current_user.id
		@com.course_teachership_id = params[:ctship]
		
		if @com.save
			render 'comment_submit'	
		else
			render :nothing => true, :status => 200, :content_type => 'text/html'	
		end
		#render :nothing => true, :status => 200, :content_type => 'text/html'
  	 	
    end
###
	
	
	def get_user_statics
		@css=current_user.course_simulations
		sem_ids=@css.map{|s|s.semester_id}
		@sems=Semester.where(:id=>sem_ids)
		#@cds=CourseDetail.where(:id=>cd_ids).order(:semester_id)
		@common_courses=@css.select{|cs|cs.course_detail.cos_type=="通識"}.map{|cs|cs.course_detail}
		#@common_courses=CourseDetail.where(:id=>cd_ids)
		render "statics"
	end
	
	def get_sem_form
		@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id} 
		render "sem_form"
	end
	def get_user_courses 
		sem_id=params[:sem_id].to_i
		cd_ids=current_user.course_simulations.filter_semester(sem_id).map{|ps| ps.course_detail.id}
		@course_details=CourseDetail.where(:id=>cd_ids).order(:cos_type ,:brief)

		@sem_id=sem_id

		@cd_all=get_mixed_info(@course_details)
		@sem=Semester.find(sem_id)

		#respond_to do |format|
    #  format.html # index.html.erb
    #  format.json { render json: @preschedules.map{|preschedule| preschedule.to_simulated } }
    #end
		@table_type="simulated"
		if params[:type]=="schd"
			#session[:saved_query]={}
			@cd_jsons=@course_details.map{|cd|{"time"=>cd.time,"class"=>cos_type_class(cd.cos_type),"room"=>cd.room,"name"=>cd.course_teachership.course.ch_name,"course_id"=>cd.id}}.to_json
			render "user_schedule"
		elsif params[:type]=="list"
			render "course_lists_mini"
		else 
			render ""
		end
	end

	def timetable
		sem_id=params[:sem_id].to_i
		@sem=Semester.find(sem_id)
		cd_ids=current_user.course_simulations.filter_semester(sem_id).map{|ps| ps.course_detail.id}
		@course_details=CourseDetail.where(:id=>cd_ids).order(:time)

		respond_to do |format|
			 format.xlsx{
			 	response.headers['Content-Type'] = "application/vnd.ms-excel"
			 	response.headers['Content-Disposition'] = " attachment; filename=\"#{@sem.name}.xls\" "	
			 }
		end
	end	
	
	def del_simu_course
		sem_id = params[:sem_id].to_i
		cid = params[:cid].to_i
		cd_ids=current_user.course_simulations.filter_semester(sem_id).select{|ps| ps.course_detail.id==cid}
		if cd_ids.size == 1
			target = current_user.course_simulations.where(:semester_id=>sem_id, :course_detail_id=>cid).first
			status = CourseDetail.where(:id=>cid).map{|cd|{"time"=>cd.time,"class"=>cos_type_class(cd.cos_type),"room"=>cd.room,"name"=>cd.course_teachership.course.ch_name,"course_id"=>cd.id}}.to_json
			target.delete	
		else
			status = 0
		end
		respond_to do |format|
       		format.html { render :text => status.to_s.html_safe }
   		end	
	end
	
	def get_user_simulated
		@sem_id=params[:sem_id].to_i
		get_autocomplete_vars
		@view_type="_mini"
		@table_type="simulated"
		
		render "srch_and_schd"
	end
	
	
	def add_simulated_course
		cd_id=params[:cd_id].to_i
		_type=params[:type]
		if params[:from]=="cart"
			session[:cd].delete(cd_id)
		end
		sem_id=params[:sem_id]
		if _type=="add"
			CourseSimulation.create(:user_id=>current_user.id, :semester_id=>sem_id, :course_detail_id=>cd_id, :score=>'通過')
		else
			CourseSimulation.where(:user_id=>current_user.id, :course_detail_id=>cd_id).destroy_all
				
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	
	def rate_cts
    ctr_id=params[:ctr_id].to_i
		score=params[:score].to_i

		@ctr=CourseTeacherRating.find(ctr_id)#:course_teachership_id =>ctr_id, :rating_type=>type).take
		etr=EachCourseTeacherRating.where(:user_id=>current_user.id, :course_teacher_rating_id=>@ctr.id).take
		if score!=0 && !etr
			EachCourseTeacherRating.create(:score=>score, :user_id=>current_user.id, :course_teacher_rating_id=>@ctr.id)
		elsif score==0
			if etr
				etr.destroy!
			end
		end
		total_rating_counts=EachCourseTeacherRating.where(:course_teacher_rating_id=>@ctr.id).count
		total_rating_sum=EachCourseTeacherRating.where(:course_teacher_rating_id=>@ctr.id).sum(:score)
		avg=total_rating_sum.to_f/total_rating_counts
		avg=avg.nan? ? 0 :avg
		@ctr.update_attributes(:total_rating_counts=>total_rating_counts, :avg_score=>avg)
		
		result={:new_score=>@ctr.avg_score.round(1), :new_counts=>@ctr.total_rating_counts, :score=>score}
		respond_to do |format|
			format.html {
				render :json => result.to_json,
							 :content_type => 'text/html',
							 :layout => false
			}
		end
	end
	def get_compare
		@course = Course.includes(:course_teacherships).find(params[:c_id])
		@teachers=@course.teachers
		@cts=@course.course_teacherships.includes(:course_teacher_ratings, :course_details)
		#@zz=@cts
		@cts_mix=@cts.zip(@teachers)
		#.sort_by{
		#	|cd| CourseTeachership.where(:course_id=>@course,:teacher_id=>cd.id).first.course_teacher_ratings.sum(:avg_score) 
		#}.reverse
		render "show_compare"
	end
	
	
  def show
		@ct=CourseTeachership.find(params[:id])
    @course = @ct.course#Course.includes(:semesters).find(params[:id])
	 
		@first_show=params[:first_show]||"tc"
=begin
		@teachers=@course.teachers.sort_by{
			|cd| CourseTeachership.where(:course_id=>params[:id],:teacher_id=>cd.id).first.course_teacher_ratings.sum(:avg_score) 
		}.reverse
		@target_rank = 999 ;
		if params[:tid]
			@teacher_show =  Teacher.find(params[:tid])
			score = CourseTeachership.where(:course_id=>params[:id],:teacher_id=>params[:tid]).first.course_teacher_ratings.sum(:avg_score) 
			if score>0
				@teachers.each_with_index do | teacher, idx|
					if teacher.id == @teacher_show.id
						@target_rank = idx+1
						break 
					end
				end		
			end
		else
			@teacher_show =  @course.teachers.first
			score = CourseTeachership.where(:course_id=>params[:id],:teacher_id=>@teacher_show.id).first.course_teacher_ratings.sum(:avg_score) 
			if score > 0
				@target_rank = 1 
			end	
		end
=end
		@target_rank=999
		#@ct=CourseTeachership.includes(:course_details).where(:course_id=>@course.id,:teacher_id=>@teacher_show.id).take
		# course_teacherships.where(:course_id=>params[:id]).course_teacher_ratings
		@sems=@course.semesters.uniq

  end
	
	def simulation
    
		@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id}
		@user_sem_ids.append(latest_semester.id)
		#if @user_sem_ids.empty?
		#	@user_sem_ids=latest_semester.id
		#end
  end
	
  def new
    @course=@department.courses.build
  end
	
  def edit
    @course = Course.find(params[:id])
  end
	
  def update
    @course = Course.find(params[:id])
	
    @course.ch_name=params[:course][:ch_name]
		@course.eng_name=params[:course][:eng_name]
    @course.save!
    redirect_to :action => :show, :id => @course
  end
	
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    redirect_to :action => :index
  end
  

	def add_to_cart
		
		if params[:type]=="add"
			ct_id=CourseTeachership.where(:course_id=>params[:cd_id], :teacher_id=>params[:tid]).take.id
			cd_id=CourseDetail.where(:course_teachership_id=>ct_id, :semester_id=>Semester.last.id).take.id
			
			if !session[:cd].include?(cd_id)
				session[:cd].append(cd_id)
				session[:cd]=CourseDetail.select(:id).where(:id=>session[:cd]).order(:time).pluck(:id)
				alt_class="success"
				title='Success'
				mesg="新增成功!"
			else
				alt_class="success"
				title='Oops'
				mesg="您已加入此課程!"		
			end
		else
			cd_id=params[:cd_id].to_i
			if session[:cd].include?(cd_id)
				session[:cd].delete(cd_id) 
				alt_class="success"
				title='Success'
				mesg="刪除成功!"
			else
				alt_class="success"
				title='Oops'
				mesg="你未加入此課程!"
			end
		end
		
		respond_to do |format|
			format.html {
				render :text => ajax_flash(alt_class,title,mesg),
							 :content_type => 'text/html',
							 :layout => false
			}
		end
		#render :nothing => true, :status => 200, :content_type => 'text/html'

		
	end
	def show_cart
		session[:saved_query]={}
		@sem=latest_semester
		@course_details=CourseDetail.where(:id=>session[:cd])
		@cd_all=get_mixed_info(@course_details)
		@table_type=params[:table_type]
		if params[:sem_id]
			@sem=Semester.find(params[:sem_id])
		end
		render "shopping_cart_list"
	end
	
	def groups
	
	end
	
	
  protected
  def find_department
    @department=Department.find(params[:department_id])
  end
  
  
  private
	
	
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
