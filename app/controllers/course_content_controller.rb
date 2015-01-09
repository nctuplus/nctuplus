class CourseContentController < ApplicationController
	include CourseContentHelper
		before_filter :checkLogin, :only=>[ :raider_list_like, :rate_cts]
		
	def raider
		ct = CourseTeachership.find(params[:ct_id])
		@ct_id = ct.id	
		case params[:type].to_i
			when 1
				@page = CourseContentHead.where(:course_teachership_id => params[:ct_id].to_i).first.presence || nil			
				render "course_content_head", :layout=>false
			when 2
				@list = CourseContentList.where(:course_teachership_id => params[:ct_id].to_i)
				render "course_content_list", :layout=>false
			when 3  #3  -> head form
				@head = CourseContentHead.where(:course_teachership_id => params[:ct_id].to_i).first.presence ||
								CourseContentHead.new(:exam_record=>0, :homework_record=>0)	
				render "content_head_form", :layout=>false
			when 4	#4 -> list form
				@list = CourseContentList.where(:course_teachership_id => params[:ct_id].to_i).presence || nil		
				render "content_list_form", :layout=>false
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
					k2.each do |hash|
						@tmp_num[@row_id.index(hash[:sem])] = hash[:num].to_i						
						score_sum = 0 
						score_count = 0
						@simu.select{|sim| sim.semester_id==hash[:sem]&&sim.course_detail_id==hash[:cdid]}.each do |s|
							if s.score.presence and numeric?(s.score) #and s.score.to_i >=60
								score_sum+= s.score.to_i
								score_count+=1
								@show_flag |= 1
							end
						end
					#	Rails.logger.debug "[debug] "+@row_name.to_s
						@tmp_score[@row_id.index(hash[:sem])][:y] = (score_count==0) ? 0 : score_sum/score_count*1.0
						@tmp_score[@row_id.index(hash[:sem])][:nums] = score_count
					end
					@res.push({:name=>k1, :data=>@tmp_num})
					@res_score.push({:name=>k1, :data=>@tmp_score})
				end			
				#Rails.logger.debug "[debug] "+ @res.to_s 
				if @res.count > 0
					@show_flag |= 2 
				end
				render "course_chart", :layout=>false
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
	
end
