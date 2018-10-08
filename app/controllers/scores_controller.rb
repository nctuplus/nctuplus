class ScoresController < ApplicationController
	include ScoresHelper
	include CourseMapsHelper
	before_filter :checkNCTULogin#, :only=>[:select_cf, :import, :gpa] (ALL need) 
	

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

			if normal.length > 0				
			        current_user.normal_scores(:course_detail).each do |course|
                                  if course.semester_id != Semester::LAST.id
                                    course.destroy
                                  elsif course.score != "修習中"
                                    course.destroy
                                  end
                                end
				current_user.agreed_scores.destroy_all
			else
				alertmesg("error",'',"匯入失敗!")
				redirect_to :back
				return
			end	
			
			@success_added 	= 0	#成功匯入
			
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

			@pass 					= 0	#過
			@drop 					= 0	#退選
			@no_pass 				= 0	#沒過
			@fail_added 		= 0	#匯入失敗
			@now_taking 		= 0 #正在修


                        # Prevent the import of course will lead to the deletion of simulation
                        # Check the last import course is the last semester or not
                        # ex: LAST:105下 CURRENT:105上
                        # => 模擬排課是放105上的內容，而成績只會匯入到104下的部分，所以會保留105上的模擬排課
                        # ex: LAST=CURRENT=105下
                        # => 匯入的成績包含105下，代表模擬排課的內容無須再保留，可刪除依最新教務系統上的選課為主
                        sem = normal.last['sem']
                        sem=Semester.where(:year=>sem[0..sem.length-2].to_i, :half=>sem[sem.length-1].to_i).take

                        if sem.id == Semester::LAST.id
                          current_user.normal_scores.destroy_all
                        end
            error_msgs = []

			normal.each do |n|
				if n['score'] == "通過" || n['score'].to_i>=current_user.pass_score
					@pass+=1
				elsif n['score'] == 'W'
					@drop+=1
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
                        error_msgs.append(
                            {:sem=>"#{n['sem']}",
                             :cos_id=>"#{n['cos_id']}",
                             :name=>"#{n['name']}",
                             :msg=>"課程不存在資料庫中"
                            })
					end
				else
					@fail_added+=1
                    error_msgs.append(
                        {:sem=>"#{n['sem']}",
                         :cos_id=>"#{n['cos_id']}",
                         :name=>"#{n['name']}",
                         :msg=>"尚未更新的學期資料"
                        })
				end
			end
            
			cm=current_user.course_maps.includes(:course_groups, :course_fields).take
			update_cs_cfids(cm,current_user)
			
			outcome_msg="匯入完成! 共新增 #{@success_added} 門課 失敗:#{@fail_added} 通過:#{@pass} 退選:#{@drop} 未通過:#{@no_pass} 修習中:#{@now_taking}"

            session[:msg] = outcome_msg
            session[:errmsg] = error_msgs
            redirect_to :action=>:select_cf
		end
	end
	
	def select_cf
        @msg = session[:msg]
        @errmsg = session[:errmsg]
	end

    # 回傳使用者已經修過的課程
    def get_courses

        # 檢查成績欄位是否已經有成績(是數字)
        #  如果沒有的話可能是 "修習中"/"退選"
        def have_score( score )
            true if score.to_i.to_s == score
        end

        @scores = Array.new()
        for score in current_user.normal_scores
            # 將 activeRecord 紀錄轉為ruby 的 hash
            score = score.to_basic_json

            next if not have_score(score[:score])
            score[:score] = score[:score].to_f

            # 針對學期做預處理(方便排序)
            half_sem = { "上"=>1, "下"=>2, "暑"=>3 }
            year = score[:sem_name][0..-2].to_i
            half = half_sem[score[:sem_name][-1]]
            score[:sem] = year*10 + half

            @scores.append(
                score.slice(
                    :sem,
                    :name,
                    :real_id,
                    :t_name,
                    :score,
                    :credit
                )
            )
        end
        # sort by semester
        @scores.sort_by!{|s| s[:sem]}.reverse!
        
        respond_to do |format|
          format.json { render :json => @scores}
          #format.html { render :json => @scores}
        end
    end

	def gpa
	end
end
