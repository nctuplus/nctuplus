class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
	include CourseHelper
  
	layout false, :only => [:course_raider, :get_user_courses, :get_user_statics, :show_cart, :get_compare]

	before_filter :checkLogin, :only=>[ :raider_list_like, :rate_cts]
	before_filter :checkE3Login, :only=>[:simulation, :add_simulated_course, :del_simu_course]
	
	def index
		@cds=custom_search
	end
	def search_mini
		@result={
			:type=>"search",
			:courses=>custom_search.map{|cd|
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
###
	
	
	def get_user_courses 
		sem_id=params[:sem_id].to_i
		cd_ids=current_user.course_simulations.filter_semester(sem_id).map{|ps| ps.course_detail.id}
		@course_details=CourseDetail.where(:id=>cd_ids).order(:cos_type ,:brief)

		@sem_id=sem_id

		@cd_all=get_mixed_info(@course_details)
		@sem=Semester.find(sem_id)

		@table_type="simulated"
		if params[:type]=="schd"
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
	@ct=CourseTeachership.find(params[:id]) 
    @course = @ct.course#Course.includes(:semesters).find(params[:id])
	 
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
		
  
  private
	def custom_search
		if params[:custom_search]&&params[:custom_search]!=""
			@q = CourseDetail.search({:course_ch_name_cont=>params[:custom_search],:semester_id_eq=>params[:q][:semester_id_eq]})
			cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department).page(params[:page])
			if cds.empty?
				@q = CourseDetail.search({:by_teacher_name_in=>params[:custom_search],:semester_id_eq=>params[:q][:semester_id_eq]})		
				cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department).page(params[:page])
			end
		else
			@q = CourseDetail.search(params[:q])
			cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department).order("semester_id DESC").page(params[:page])
		end
		return cds
	end
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
