class ScoresController < ApplicationController
	include ScoresHelper
	include CourseMapsHelper
	before_filter :checkNCTULogin#, :only=>[:select_cf, :import, :gpa] (ALL need) 
	require 'spreadsheet'
	
	def import_json
          spreadsheet = open_spreadsheet(params[:json])
          spreadsheet.delete_at(0)
          res = Hash.new()
          user_info = Hash.new()

          spreadsheet.each do |row|
            if user_info[row[0]].nil?
              user_info[row[0]] = {
                :year=>row[3],
                :year_now=>Semester::CURRENT.year,
                :half_now=>Semester::CURRENT.half,
                :degree=>3,
                :student_id=>row[0]
              }
            end
            if res[row[0]].nil? then res[row[0]] = [] end
            sem_name = row[4];
            if row[5] == "1" then sem_name += "上" else sem_name += "下" end
            cf_id = Course.find_by(:real_id=>row[9]).course_field_lists.last.try(:course_field_id)
            if cf_id.nil? then cf_name = nil else cf_name = CourseField.find(cf_id).name end
            res[row[0]].append({
              :name=>row[8],
              :cos_id=>row[6],
              :read_id=>row[9],
              :cd_id=>'',
              :sem_name=>sem_name,
              :t_name=>'',
              :temp_cos_id=>'',
              :brief=>'',
              :score=>row[15],
              :credit=>'',
              :cos_type=>row[11],
              :id=>'',
              :cf_id=>cf_id,
              :cf_name=>cf_name,
              :pass_score=>60,
              :memo=>''
            })
          end

          course_map = CourseMap.find(156)
          map = (course_map.presence) ? course_map.to_tree_json : nil
          alertmesg('info','warning', user_info['777777'])
          # alertmesg('info','warning', res['777777'])
          # redirect_to user_statistics_table_path(user_info: user_info['777777'], data1: map, data2: res['777777'])
          redirect_to :back
	end

        def open_spreadsheet(file)
          case File.extname(file.original_filename)
          when ".csv" then CSV.read(file.path, :encoding => 'big5:utf-8') # Roo::CSV.new(file.path, options{})
          else raise "Unknown file type: #{file.original_filename}"
          end
        end

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
				current_user.normal_scores.destroy_all
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
					end
				else
					@fail_added+=1
				end
			end		
			cm=current_user.course_maps.includes(:course_groups, :course_fields).take
			update_cs_cfids(cm,current_user)
			
			msg="匯入完成! 共新增 #{@success_added} 門課 失敗:#{@fail_added} 通過:#{@pass} 退選:#{@drop} 未通過:#{@no_pass} 修習中:#{@now_taking}"
			redirect_to :action=>:select_cf, :msg=>msg
		end
	end
	
	def select_cf
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
