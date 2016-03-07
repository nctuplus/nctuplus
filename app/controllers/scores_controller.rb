class ScoresController < ApplicationController
	include ScoresHelper
	include CourseMapsHelper
	before_filter :checkE3Login, :only=>[:import_confirm, :import, :gpa]
	

	def import
		if current_user.department.nil?
			alertmesg("info",'Oops',"請先輸入您的系級，謝謝!")
			redirect_to "/user/edit"
		end
		if request.post?

			if params[:user_agreement].to_i == 0
				redirect_to :action =>"show"
				return
			end

			score=params[:course][:score]
			res=parse_scores(score)
			agree=res[:agreed]
			normal=res[:taked]

			dept=res[:dept]
			
			if res[:student_id] != current_user.student_id
				alertmesg("error",'',"請匯入自己的成績，謝謝!")
				redirect_to :back
				return
			end
			
			has_added=0
			@success_added=0
			@fail_added=0

			@no_pass=0
			@pass=0
			
			if normal.length > 0				
				current_user.normal_scores.destroy_all
				current_user.agreed_scores.destroy_all
			else
				alertmesg("error",'',"匯入失敗!")
				redirect_to :back
				return
			end	

			agree.each do |a|
				course=Course.where(:real_id=>a[:real_id]).take
				if course.nil?
					course=Course.create(
						:real_id=>a[:real_id],
						:ch_name=>a[:ch_name],						
						:eng_name=>a[:memo],
						:credit=>a[:credit],
						:is_virtual=>true
					)
				end
				AgreedScore.create_form_import(current_user.id,course.id,a)
				@success_added+=1
			end
			@now_taking=0
			normal.each do |n|
				if n['score']=="通過" || n['score'].to_i>=current_user.pass_score
					@pass+=1
				elsif n['score']==""
					@now_taking+=1
				else
					@no_pass+=1
				end
				sem=n['sem']
				sem=Semester.where(:year=>sem[0..sem.length-2].to_i, :half=>sem[sem.length-1].to_i).take
				if sem
					cd=CourseDetail.where(:semester_id=>sem.id, :temp_cos_id=>n['cos_id']).take
					if cd
						NormalScore.create_form_import(current_user.id,cd.id,n)
						@success_added+=1
					else
						@fail_added+=1
					end
				else
					@fail_added+=1
				end
			end		
			cm=current_user.course_maps.includes(:course_groups, :course_fields).take
			update_cs_cfids(cm,current_user)
			
			msg="匯入完成! 共新增 #{@success_added} 門課 失敗:#{@fail_added} 通過:#{@pass} 未通過:#{@no_pass} 修習中:#{@now_taking}"
			redirect_to :action=>"import_confirm", :msg=>msg
		end
	end
	def import_confirm	#import step2 choose cm, view only
	end

	def gpa
		@normal_scores = current_user.normal_scores
		@sum = 0.0
		@sum2 = 0.0
		@credit = 0

		@sum60 = 0.0
		@sum6043 = 0.0
		@credit60 = 0
	end
end
