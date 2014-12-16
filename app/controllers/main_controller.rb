class MainController < ApplicationController
  #require 'coderay'
  require 'open-uri'
  require 'net/http'
  require 'json'
	#layout false, :only => [:test_p, :search_by_keyword, :search_by_dept]
	before_filter :redirect_to_user_index, :only=>[:index]
	#before_filter :cors_preflight_check, :only=>[:zzz]
	before_filter :checkTopManager, :only=>[:student_import]
	#test
	include CourseMapsHelper	
	include ApiHelper
	
  def index
		
		#@course_detail_count=CourseDetail.all.count
		#@file_count=FileInfo.count
		
		#@user_count=User.count
		
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
	
	def testttt
		
		http=Curl.post("http://dcpc.nctu.edu.tw/plug/n/nctup/DepartmentList",{})
		@all=JSON.parse(http.body_str.force_encoding("UTF-8"))		
	end
	
	def updateTeacherList
		http=Curl.get("http://dcpc.nctu.edu.tw/plug/n/nctup/TeacherList",{})
		teachers=JSON.parse(http.body_str.force_encoding("UTF-8"))
		
		tids=teachers.map{|t|t["TeacherId"]}
		@deleted=NewTeacher.update_all({:is_deleted=>true},["real_id NOT IN (?)",tids])
		all_now=NewTeacher.all.map{|t|{"TeacherId"=>t.real_id, "Name"=>t.name}}
		@new=teachers - all_now
		@new.each do |t|
			@teacher=NewTeacher.new
			@teacher.real_id=t["TeacherId"]
			@teacher.name=t["Name"]
			@teacher.save!
		end
	end
	def test
		data =  {'OrgId' => '46804706', 'VirtualAccount' => '95306617687250'}
		http = Curl.post("https://easyfee.esunbank.com.tw/payciweb/vacntQuery.action", data)
		@response = http.body_str.force_encoding("UTF-8")#JSON.parse(http.body_str.force_encoding("UTF-8"))
				
	end
	
	def send_report
		@name=params[:report][:name]
		@email=params[:report][:email]
		
		if current_user
			@email='https://www.facebook.com/'<<current_user.uid
		end
		
		@content=params[:report][:content]
		UserMailer.report(@name,@email,@content).deliver
		#render :nothing => true, :status => 200, :content_type => 'text/html'
		render "send_success"
	end
	
	
	def hidden_prepare
		
		#prepare_course_db
		#final_set_dept_type
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
  private
	
	def final_set_dept_type
		Department.where("dept_type!='for_user'").each do |d|
			if d.courses.count == 0
				d.update_attributes(:dept_type=>"no_courses")
			else
				if d.real_id[0]<='Z'&&d.real_id>='A'
					if d.real_id[0]=='U'
						d.update_attributes(:dept_type=>"common")
					else
						d.update_attributes(:dept_type=>"college")
					end
				else
					d.update_attributes(:dept_type=>"dept")
				end
			end
		end
	end
	
	
  def change_to_grad_degree(real_id)
    @old=Department.where(:degree=>'3', :real_id=>real_id).take.id
		@new=Department.where(:degree=>'2', :real_id=>real_id).take.id
		Course.where(:department_id=>@old).each do |c|
			c.update_attributes(:department_id=>@new)
		end
		Teacher.where(:department_id=>@old).each do |t|
			t.update_attributes(:department_id=>@new)
		end
  end

  def destroy_course
    Course.destroy_all
    Teacher.destroy_all
  end
  def save_sem_courseship(sem_id,course_id)
    #sem_id=Semester.find_by_real_id(sem_real_id).id
		unless SemesterCourseship.where(:semester_id=>sem_id,:course_id=>course_id).take
			SemesterCourseship.create(:semester_id=>sem_id,:course_id=>course_id)
		end
  end
  def prepare_course_db
  #year=['103']
	#sem=['1']
    #year=['103','102','101','100']
	#sem=['2','1']
	
		Semester.all.each do |sem|
			data=parse_course(sem.year,sem.half)
			if save_courses(data,sem.year,sem.half)
				change_to_grad_degree("12")
				change_to_grad_degree("13")
			end
		end
	
  end
  def do_save_courses(sem_id,data)
    data.each do |key1,value1|
	#@html<<value1['cos_cname']<<value1['cos_ename']<<value1['teacher']<<"<br>"
			@dept=Department.where(:degree=>value1['degree'], :real_id=>value1['dep_id']).take
			next if @dept.nil?
			dept_id=@dept.id
			teacher=save_teacher(value1['teacher'],dept_id)
			course=save_course(value1['cos_code'],value1['cos_cname'],value1['cos_ename'],dept_id)
			@cts=save_course_teacher(teacher.id,course.id)
			save_course_teacher_rating(@cts.id)
			save_course_detail(@cts.id,sem_id,value1)
			#save_sem_courseship(sem_id,course.id)
		end
  end
	def save_course_teacher_rating(cts_id)
		return if CourseTeacherRating.where(:course_teachership_id=>cts_id).take
		_type=["cold","sweety","hardness"]
		_type.each do |t|
			CourseTeacherRating.create(:course_teachership_id=>cts_id, :rating_type=>t, :avg_score=>0, :total_rating_counts=>0)
		end
	end
	def save_course_teacher(teacher_id,course_id)
		@cts=CourseTeachership.where(:teacher_id=>teacher_id,:course_id=>course_id).take
    @cts=CourseTeachership.create(:teacher_id=>teacher_id,:course_id=>course_id) if @cts.nil?
		
		return @cts
	end
  def save_courses(data,year,sem)
	@sem= Semester.where(:year=>year,:half=>sem).take
	if @sem
		sem_id=@sem.id
	else 
		return false
	end
    data.each do |data1|
	  data1.each do |data2|#|key,value|
	    next if data2.empty?
	    data2.each do |key,value|
		  data3=value.fetch('1',[])
		  do_save_courses(sem_id,data3)
		  #data4=value.fetch('2',[])
		  #do_save_courses(sem_id,data4)		  
		end
	  end
	end
	return true
  end
  def parse_semester
    year=(99..103)
		semester=(1..2)
		name=['上','下']
		year.each do |y|
			semester.each do |s|
				sem=Semester.new(:year=>y.to_s, :half=>s.to_s)
				sem.name=y.to_s+name[s-1]
				sem.save
			end
		end
  end
  def save_course_detail(cts_id,sem_id,raw_data)
    @cd=CourseDetail.where(:temp_cos_id=>raw_data['cos_id'], :semester_id=>sem_id).take
    if @cd.nil?
	  #@department
			@cd=CourseDetail.new
			@cd.course_teachership_id=cts_id
			@cd.semester_id=sem_id
			@cd.credit=raw_data['cos_credit']
			costime=raw_data['cos_time'].split(',')
			@cd.time=""
			@cd.room=""
			costime.each do |t|
				@cd.time<<t.partition('-')[0]
				@cd.room<<t.partition('-')[2]
			end
			#@cd.time=raw_data['cos_time'].partition('-')[0]
			#@cd.room=raw_data['cos_time'].partition('-')[2]
			@cd.memo=raw_data['memo']
			@cd.students_limit=raw_data['num_limit']
			@cd.reg_num=raw_data['reg_num']
			
			if raw_data['degree']=="0"&&(raw_data['cos_type']=="必修"||raw_data['cos_type']=="選修")
				@cd.cos_type="共同"<<raw_data['cos_type']
			else
				@cd.cos_type=raw_data['cos_type']
			end
			@cd.temp_cos_id=raw_data['cos_id']
			@cd.brief=raw_data['brief']
			@cd.save
	  
		#else
		#  return nil
		end
		return @cts
  end
  def save_course(code,ch_name,eng_name,dept_id)
    @course=Course.find_by_real_id(code)
    if @course.nil?
	  #@department
	  @course=Course.new(:ch_name=>ch_name,:eng_name=>eng_name,:real_id=>code,:department_id=>dept_id)
	  @course.save
	  
		#else
		#  return nil
		end
			return @course
  end
  def save_teacher(name,dept_id)
    @teacher=Teacher.find_by_name(name)
    if @teacher.nil?
	  #@department
	  #dep_id=Department.find_by_real_id(real_id).id
	  
	  @teacher=Teacher.new(:name=>name,:department_id=>dept_id)
	  @teacher.save
	  
	#else
	#  return nil
	end
	return @teacher
  end
  
  def parse_course(year,sem)
	
	#total length is 248 so take 31 for each thread
  @dept_real_id=Department.where("dept_type!='for_user'").map{|d|d.degree+d.real_id}
	@slice=31
	
	threads=[]
	(0..7).each do |i| 
	 threads<<Thread.new{Thread.current[:output] = get_course(@dept_real_id,i*@slice,@slice,year,sem)} 

	end 

	#@html=""

	data=[]
	threads.each do |t| 
	  t.join
	  data.append(t[:output])
	end
	return data
  end
  def parse_college
    @type=[3]
	
    data=Array.new
    @type.each do |_type|
	  @send={"ftype"=>_type,"fcategory"=>_type.to_s+'*',"flang" =>'zh-tw'}
	  http=Curl.post("http://timetable.nctu.edu.tw/?r=main/get_college",@send)
	  @college=JSON.parse(http.body_str.force_encoding("UTF-8"))
	  @college.each do |college|
		College.create(:name=>college['CollegeName'], :real_id=>college['CollegeNo'])
	  end
	  
	end
	return data
  end
	def parse_dep_next3
		ftype=['7','72','8']
		fcategory='0C'
		ftype.each do |_type|
			@payload={"acysem"=>'1031', "ftype"=>_type,"fcategory"=>fcategory,
						 "fcollege"=>'*', "flang" =>'zh-tw'}
			http=Curl.post("http://timetable.nctu.edu.tw/?r=main/get_dep",@payload)
			@result=JSON.parse(http.body_str.force_encoding("UTF-8"))
		  @result.each do |result1|
		    next if result1["unit_id"].nil?
		    next if Department.where(:degree=>result1['unit_id'][0], :real_id=>result1['unit_id'][1..2]).take
				department=Department.new
				department.degree=result1['unit_id'][0]
				department.real_id=result1['unit_id'][1..2]
				department.ch_name=result1['unit_name']
				department.dept_type="temp"
				department.college_id=1
				department.save!
		  end
		end
	end
  def parse_dep_prev3
    @type=[3,2,0]#7,72,8] 
	
    data=Array.new
    @type.each do |_type|
	#@sendE3={:key=>Nctuplus::Application.config.secret_key_base,:id=>"0011566",:pwd=>"ffffff"}
	  @send={"ftype"=>_type,"flang" =>'zh-tw'}
	  http=Curl.post("http://timetable.nctu.edu.tw/?r=main/get_category",@send)
	  @category=JSON.parse(http.body_str.force_encoding("UTF-8"))
	  @category.each do |key,value|
		#@html<<value
	    College.all.each do |college|
		  @payload={"acysem"=>'1031', "ftype"=>_type,"fcategory"=>key,
		       "fcollege"=>college.real_id, "flang" =>'zh-tw'}
		  http=Curl.post("http://timetable.nctu.edu.tw/?r=main/get_dep",@payload)
		  
		  @result=JSON.parse(http.body_str.force_encoding("UTF-8"))
		  @result.each do |result1|
		    next if result1["unit_id"].nil?
		    next if Department.where(:degree=>result1['unit_id'][0], :real_id=>result1['unit_id'][1..2]).take
			department=Department.new
			department.degree=result1['unit_id'][0]
			department.real_id=result1['unit_id'][1..2]
			department.ch_name=result1['unit_name']
			department.college_id=college.id
			department.save!
		  end
		  #@result.college_id=college.id
		  #@result
		  #@result.merge({'college_id'=>college.id}.to_json)
		  #data.append(@result)		  
	    end
	  end
	end
	#Department.destroy_all(:degree=>'3', :real_id=>"11")
	#Department.destroy_all(:degree=>'3', :real_id=>"12")
	#Department.destroy_all(:degree=>'3', :real_id=>"13")
	#return data
  end
 
  def get_course(dept_real_id,begin_dep_id,num_to_get,year,sem)
	data=[]
	  (begin_dep_id..(begin_dep_id+num_to_get)).each do |index|
	    break if index>=dept_real_id.length
		dept_id=dept_real_id[index]#real_id
		#break if department.id>=50
		@payload = {"m_acy" => year, 'm_sem' => sem, 'm_degree'=>dept_id[0], 'm_dep_id'=>dept_id[1..2],'m_group'=>'**',
			'm_grade'=>'**','m_class'=>'**','m_option'=>'**','m_crsname'=>'**','m_teaname'=>'**','m_cos_id'=>'**',
			'm_cos_code'=>'**','m_crstime'=>'**','m_crsoutline'=>'**'}#.to_json
		http=Curl.post("http://timetable.nctu.edu.tw/?r=main/get_cos_list",@payload)
		
		@result=JSON.parse(http.body_str.force_encoding("UTF-8"))
		data.append(@result)
	  end
	#end
	return data
  end
	
  
  
end
