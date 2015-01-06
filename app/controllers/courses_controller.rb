class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
	include CourseHelper
  
	layout false, :only => [:course_raider, :get_user_courses, :get_user_statics, :show_cart, :get_compare]

	before_filter :checkLogin, :only=>[ :raider_list_like, :rate_cts]
	before_filter :checkE3Login, :only=>[:simulation, :add_simulated_course, :del_simu_course]
	
	def index
		@cds=custom_search(true,true)
	end
	def search_mini
		@result={
			:view_type=>"schedule",
			:use_type=>"add",
			:courses=>custom_search(!params[:q].blank?,false).map{|cd|
				cd.to_search_result
			}
		}
		render "courses/search/mini", :layout=>false
	end
	
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
	
	
	def rate_cts
    ct=CourseTeachership.find(params[:ct_id])
		score=params[:score].to_i
		
		case params[:r_type]
			when "cold"
				r_type=1
				
			when "sweety"
				r_type=2
				
			when "hardness"
				r_type=3
			else 
				return
			
		end
		@ntr=NewCourseTeacherRating.find_or_create_by(:user_id=>current_user.id, :course_teachership_id=>params[:ct_id],:rating_type=>r_type)
		if score==0
			@ntr.destroy
		else
			@ntr.score=score
			@ntr.save!
		end
		case params[:r_type]
			when "cold"
				target=ct.cold_ratings
			when "sweety"
				target=ct.sweety_ratings
			when "hardness"
				target=ct.hardness_ratings
			else 
				return
		end
		
		#render :nothing => true, :status => 200, :content_type => 'text/html'

		result={:avg_score=>target.avg_score, :rate_count=>target.rate_count, :score=>score}
		respond_to do |format|
			format.html{render :layout=>false,:nothing =>true }
			format.json{render json:result}
		end

	end
	def get_compare
		@course = Course.includes(:course_teacherships).find(params[:c_id])

		@cts=@course.course_teacherships.includes(:new_course_teacher_ratings, :course_details)
		@ct_compare_json=[]
		@user_rated_json=[]
		t_name=[]
		@cts.includes(:new_course_teacher_ratings).each do |ct|
			next if t_name.include?(ct.teacher_name)
			t_name.push(ct.teacher_name)
			
			cold_ratings=ct.cold_ratings
			sweety_ratings=ct.sweety_ratings
			hardness_ratings=ct.hardness_ratings
			
			res={
				:id=>ct.id,
				:name=>ct.teacher_name,
				:cold=>cold_ratings,
				:sweety=>sweety_ratings,
				:hardness=>hardness_ratings,
			}
			user_ratings={
				:cold=>!cold_ratings.nil? && !cold_ratings.arr.select{|cr|cr.user_id==current_user.id}.empty? ,
				:sweety=>!sweety_ratings.nil? && !sweety_ratings.arr.select{|cr|cr.user_id==current_user.id}.empty? ,
				:hardness=>!hardness_ratings.nil? && !hardness_ratings.arr.select{|cr|cr.user_id==current_user.id}.empty?
			}
			@ct_compare_json.push(res)
			@user_rated_json.push(user_ratings)
		end
		render "show_compare"
	end
	
	
  def show
		cd=CourseDetail.find(params[:id])
		cd.incViewTimes!

		@ct=cd.course_teachership
		@course = @ct.course#Course.includes(:semesters).find(params[:id])
		@cds=@ct.course_details.includes(:semester,:department)
		zz=@ct.cold_ratings.avg_score
		@first_show=params[:first_show]||"tc"
		@target_rank=999
		@sems=@course.semesters.uniq

  end
	
  def simulation  
		@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id}
		@user_sem_ids.append(latest_semester.id)	
  end
	
	def add_to_cart
		
		if params[:type]=="add"
			cd_id=params[:cd_id].to_i
			session[:cd]=[] if !session[:cd]
			if CourseDetail.where(:id=>cd_id).empty?
				alt_class="warning"
				mesg="查無此門課!"
			else
				if !session[:cd].include?(cd_id)
					session[:cd].append(cd_id)
					session[:cd]=CourseDetail.select(:id).where(:id=>session[:cd]).order(:time).pluck(:id)
					alt_class="success"
					mesg="新增成功!"
				else
					alt_class="info"
					mesg="您已加入此課程!"		
				end
			end
		else
			cd_id=params[:cd_id].to_i
			if session[:cd].include?(cd_id)
				session[:cd].delete(cd_id) 
				alt_class="success"
				mesg="刪除成功!"
			else
				alt_class="warning"
				mesg="你未加入此課程!"
			end
		end
		
		respond_to do |format|
			format.html {
				render :text => ajax_flash(alt_class,title,mesg),
							 :content_type => 'text/html',
							 :layout => false
			}
			format.json {
				render :json => {:class=>alt_class, :text=>mesg}
			}
		end
		#render :nothing => true, :status => 200, :content_type => 'text/html'

		
	end
	

	
	def show_cart
		@result={
			:view_type=>"session",
			:use_type=>"delete",
			:courses=>CourseDetail.where(:id=>session[:cd]).map{|cd|
				cd.to_search_result
			}
		}
	end
		
  
  private
	def custom_search(showDefault,pageble)
		if params[:custom_search]&&params[:custom_search]!=""
			@q = CourseDetail.search({:course_ch_name_cont=>params[:custom_search],:semester_id_eq=>params[:q][:semester_id_eq]})
			cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses)
			if cds.empty? #search teacher
				@q = CourseDetail.search({:by_teacher_name_in=>params[:custom_search],:semester_id_eq=>params[:q][:semester_id_eq]})		
				cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses)
				if cds.empty? #search time
					@q = CourseDetail.search({:time_cont=>params[:custom_search],:semester_id_eq=>params[:q][:semester_id_eq]})		
					cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses)
				end
			end
		else
			if showDefault
				@q = CourseDetail.search(params[:q])
			else
				@q=CourseDetail.search({:id_in=>[0]})
			end
			cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses).order("semester_id DESC")
		end
		
		cds=cds.order("view_times DESC")

		return pageble ? cds.page(params[:page]) : cds
	end
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
