class CourseContentController < ApplicationController
	include CourseContentHelper
		before_filter :checkLogin, :only=>[ :course_action, :rate_cts]
		
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
	
	def show # for testing
		cd=CourseDetail.find(25600)
		cd.incViewTimes!

		@data = {
			:course_id=>cd.course.id.to_s,
			:course_detail_id=>cd.id.to_s,
			:course_teachership_id=>cd.course_teachership.id.to_s,
			:course_name=>cd.course_ch_name,
			:course_teachers=>cd.teacher_name,
			:course_real_id=>cd.course.real_id.to_s,
			:course_credit=>cd.course.credit,
			:open_on_latest=>(cd.course_teachership.course_details.last.semester==latest_semester) ? true : false ,
			:related_cds=>cd.course_teachership.course_details.includes(:semester,:department).order("semester_id DESC")
		}
		
	end

	def get_course_info
		data = {}
		cd = CourseDetail.find(params[:cd_id])
		case params[:content]
			when 'chart'
				data = cd.course.to_chart(latest_semester)			
			when 'content_head'
				data = cd.course_teachership.try(:course_content_head).try(:to_hash)  || {}
			when 'content_lists'
				istop = checkTopManagerNoReDirect
				data = cd.course_teachership.try(:course_content_lists).includes(:user).order('updated_at DESC')
					   .map{ |list| list.to_content_list(((current_user==list.user)||istop), current_user) } || {}	
			when 'course_comments'
				data = cd.course_teachership.comments.order('updated_at ASC').map{|c| c.to_hash}
		end 
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>data.to_json}
    	end
	end	
	
	def course_action
		data = {}
		case params[:type]
			when 'content-head'
				ct = CourseDetail.find(params[:cd_id]).course_teachership
				ch = ct.try(:course_content_head)
				if ch
					ch.update_attributes(:exam_record=>params[:exam_data], :homework_record=>params[:hw_data], 
							:course_rollcall=>params[:rollcall], :last_user_id=>current_user.id)
				else
					ch = CourseContentHead.new
					ch.course_teachership_id = ct.id
					ch.exam_record, ch.homework_record = params[:exam_data], params[:hw_data]
					ch.course_rollcall = params[:rollcall]
					ch.last_user_id = current_user.id
					ch.save!
				end
				data = ch.to_hash
			when 'content-list-edit'
				list = CourseContentList.find(params[:list_id])	
				if not (list.content_type==params[:list_type].to_i and list.content==params[:list_content])		
					list.update_attributes(:user_id=>((checkTopManagerNoReDirect) ? list.user_id : current_user.id) ,
					:content_type=>params[:list_type], :content=>params[:list_content]) 
					ismy = (current_user==list.user)||checkTopManagerNoReDirect
					data = list.to_content_list(ismy, current_user)	
					data[:update] = true
				else
					ismy = true
					data = list.to_content_list(ismy, current_user)	
					data[:update] = false
				end		
							
			when 'content-list-delete'
				list = CourseContentList.find(params[:list_id])
				list.destroy
			when 'content-list-new'
				ct = CourseDetail.find(params[:cd_id]).course_teachership
				list = CourseContentList.new
				list.user_id, list.course_teachership_id  = current_user.id, ct.id 
				list.content_type, list.content =params[:list_type], params[:list_content]
				list.save!
				data = list.to_content_list(true, current_user)
			when 'content-list-rank'
				list = CourseContentList.find(params[:list_id])
				new_rank = ContentListRank.new
				new_rank.course_content_list_id = list.id
				new_rank.user_id, new_rank.rank = current_user.id, params[:rank_type]
				new_rank.save!
			when 'comment-new'	
				cd = CourseDetail.find(params[:cd_id])
				comment = Comment.new
				comment.user_id, comment.course_teachership_id = current_user.id, cd.course_teachership.id
				comment.content_type, comment.content = params[:comment_type], params[:comment_content]
				comment.save!
				data = comment.to_hash
		end
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>data.to_json}
    	end
	end
	
end
