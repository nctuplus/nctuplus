class MainController < ApplicationController
  #require 'coderay'
  require 'open-uri'
  require 'net/http'
  require 'json'

	#before_filter :redirect_to_user_index, :only=>[:index]
	before_filter :checkTopManager, :only=>[:student_import]
	include CourseMapsHelper	
	include ApiHelper
	def policay_page
	end
	
  def index
  end
	
	def E3Login_Check
		
		std_id = params[:id]
		
		@sendE3={:key=>Nctuplus::Application.config.secret_key_base ,:id=>std_id, :pwd=>params[:pwd]}		
		http=Curl.post("http://dcpc.nctu.edu.tw/plug/n/nctup/Authentication",@sendE3)
		@res=http.body_str
		Rails.logger.debug "[debug] res="+@res.to_s
		data = 'fail'
		
		if @res.to_s=='"OK"'
			find_user = User.where(:student_id=>std_id).take
			
			if current_user and find_user #有兩個獨立的帳號(fb, e3), merge	
				if find_user.uid.nil?
					if not find_user.course_simulations.empty? 
						current_user.course_simulations.destroy_all # fb cs delete
						find_user.course_simulations.each do |cs| #有save ? # move e3 cs
							cs.user_id = current_user.id
							cs.save!
						end
					end
					current_user.student_id = find_user.student_id
					find_user.destroy
					current_user.save!
				else
					alertmesg("info",'Sorry','綁定失敗')  		
				end
			elsif current_user and not find_user #只有fb
				current_user.student_id = std_id
				current_user.save!
				current_user.course_simulations.destroy_all 
				alertmesg("info",'success',"綁定成功！ 成績資訊須重新匯入請注意！！") 
			elsif not current_user and find_user #僅知有e3
				session[:user_id] = find_user.id
			else  # 僅知沒e3
				new_user = User.new	
				new_user.student_id, new_user.name = std_id, std_id
				new_user.save!
				session[:user_id] = new_user.id
			end			
			data = 'success'		
		end
		
		render :text=> data
	end
	
	

	

	def get_specified_classroom_schedule
  	if params[:token_id]=="ems5566"
  		@data = CourseDetail.where(:semester_id=>Semester.last.id, :room=>params[:room]).includes(:course)	
  		respond_to do |format|
   	 		format.json { render :layout => false, :text => @data.map{|d| [d.course.ch_name, d.time, d.reg_num] }.to_json }
    	end
    end
  end	
  	
	def student_import
		if request.post?
			score=params[:course][:score]
			res=parse_scores(score)				
			agree=res[:agreed]
			normal=res[:taked]
			student_id=res[:student_id]
			student_name=res[:student_name]
			dept=res[:dept]
			@pass_score=60
			has_added=0
			@success_added=0
			@fail_added=0
			fail_course_name=[]
			@no_pass=0
			@pass=0
			if normal.length>0
				TempCourseSimulation.where(:student_id=>student_id).destroy_all
			end
			agree.each do |a|
				course=Course.includes(:course_details).where(:real_id=>a[:real_id]).take
				unless course.nil?
					cd_temp=course.course_details.first
					@success_added+=1
					TempCourseSimulation.create(:name=>student_name, :student_id=>student_id,:dept=>dept, :course_detail_id=>cd_temp.id, :semester_id=>0, :score=>"通過",
												:memo=>a[:memo], :has_added=>0, :cos_type=>a[:cos_type])
				else
				#if failed,set course_detail_id to 0
					TempCourseSimulation.create(:name=>student_name, :student_id=>student_id,:dept=>dept, :course_detail_id=>0, :semester_id=>0, :score=>"通過",
											:memo=>a[:memo], :has_added=>0, :memo2=>a[:real_id]+"/"+a[:credit].to_s+"/"+a[:name], :cos_type=>a[:cos_type])
					@fail_added+=1
				end			
			end

			normal.each do |n|
				#dept_id=Department.select(:id).where(:ch_name=>n['dept_name']).take
				if n['score']=="通過" || n['score'].to_i>=@pass_score
					@pass+=1
				else
					@no_pass+=1
				end
				sem=n['sem']
				sem=Semester.where(:year=>sem[0..sem.length-2].to_i, :half=>sem[sem.length-1].to_i).take
				if sem
					cds=CourseDetail.where(:semester_id=>sem.id, :temp_cos_id=>n['cos_id']).take
					if cds	
						TempCourseSimulation.create(:name=>student_name, :student_id=>student_id,:dept=>dept, :course_detail_id=>cds.id, :semester_id=>cds.semester_id, :score=>n['score'],
													:has_added=>0, :cos_type=>n['cos_type'])
						@success_added+=1
					else
						#fail_course_name.append()
						@fail_added+=1
					end
				else
					@fail_added+=1
				end
			end
	
			data = TempCourseSimulation.uniq.pluck(:student_id, :name, :dept, :has_added)
			render :text=>{:data=>data, :fail=>@fail_added.to_s}.to_json
		end# request.post
	
		if params[:type]=='delete'
			stdid = params[:student_id]
			TempCourseSimulation.where(:student_id=>stdid).destroy_all				
		end
	
		respond_to do |format|
			format.html {}
			format.json {render :layout => false, :text=>{
				:data=>TempCourseSimulation.uniq.order("student_id").pluck(:student_id, :name, :dept, :has_added)}.to_json 
			}
		end
	end# def student_import
  	
	def temp_student_action
		stdid = params[:student_id]
		if params[:type]=='delete'
			TempCourseSimulation.where(:student_id=>stdid).destroy_all
			render :text=>"ok"
		else
			tcs = TempCourseSimulation.where(:student_id=>stdid)
			data = {:fails=>tcs.select{|cs| cs.course_detail_id==0}.count}
			tmp1 = []
			tcs.each do |cs|
				if cs.course_detail_id==0
					name = "No match"
				else
					name = CourseDetail.find(cs.course_detail_id).course.ch_name
				end
				tmp2 = {:name=>name}
				tmp1.push(tmp2)
			end
			data[:nodes] = tmp1
			render :layout=>false, :text=>data.to_json
		end
	end
  
end
