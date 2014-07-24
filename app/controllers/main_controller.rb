class MainController < ApplicationController
  #require 'coderay'
  require 'open-uri'
  require 'net/http'
  require 'json'
	#layout false, :only => [:test_p, :search_by_keyword, :search_by_dept]
	
  def index
		@course_detail_count=CourseDetail.all.count
		@file_count=FileInfo.count
		@review_count=Review.count
		@user_count=User.count
		
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
		#_type=["cold","sweety","hardness"]
		#
		#CourseTeachership.all.each do |ct|
		#	_type.each do |t|
		#		CourseTeacherRating.create(:course_teachership_id=>ct.id, :rating_type=>t, :avg_score=>0, :total_rating_counts=>0)
		#	end
		#end
	end
	
	
	
	
  

	# def search_by_keyword_ajax
    # search_term=params[:_search_term]
		# search_type=params[:_search_type]
		# semester_id=params[:_semester_id].to_i
		# dept_id=params[:_dept_id]
		
		# dept_ids= get_dept_ids(dept_id)
				
		# case search_type
			# when "course_no"
				# if !semester_id.nil?
					# @courses= Course.where(" id IN (:id) AND real_id LIKE :real_id ",
							# { :id=>SemesterCourseship.select("course_id").where(:semester_id=> semester_id), :real_id => "%#{search_term}%" })	
				# else
					# @courses= Course.where("real_id LIKE :real_id ",
																# {:real_id => "%#{search_term}%" })#, :id=> SemesterCourseship.select("course_id").where(:semester_id=> "8"))		
				# end
				# @courses=@courses.select{|c| join_dept(c,dept_ids) } if dept_ids
				
			# when "course_name"
				# if !semester_id.nil?
					# @courses = Course.where("id IN (:id) AND ch_name LIKE :name ",
						# {:id=>SemesterCourseship.select("course_id").where(:semester_id=> semester_id), :name => "%#{search_term}%" })
				# else
					# @courses= Course.where("ch_name LIKE :name ",
																# {:name => "%#{search_term}%" })#, :id=> SemesterCourseship.select("course_id").where(:semester_id=> "8"))		
				# end
				# @courses=@courses.select{|c| join_dept(c,dept_ids) } if dept_ids
		# end
		# respond_to do |format|
			# format.html {
				# render :json => @courses.map{|course|
														# course.course_details.flit_semester(semester_id).map{|cd|cd.to_result(course) }
												# },
					# :content_type => 'text/html',
					# :layout => false
			# }
		# end
  # end
	
  # def search_by_dept_ajax
		# dept_id=params[:_dept_id]
		# semester_id=params[:_semester_id].to_i
		
		# dept_ids=get_dept_ids(dept_id)
		
		# @semester=Semester.find(semester_id)
		# @courses=@semester.courses.select{|c| join_dept(c,dept_ids)}

		# respond_to do |format|
			# format.html {
				# render :json => @courses.map{|course|
														# course.course_details.flit_semester(semester_id).map{|cd|cd.to_result(course) }
												# },
					# :content_type => 'text/html',
					# :layout => false
			# }
		# end
	# end
	
  private
	
	def final_set_dept_type
		Department.all.each do |d|
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
    year=['103','102','101','100']
	sem=['2','1']
	year.each do |y|
		sem.each do |s|
			data=parse_course(y,s)
			if save_courses(data,y,s)
			change_to_grad_degree("12")
			change_to_grad_degree("13")
			end
			#set_department_type
		end
	end
  end
  def do_save_courses(sem_id,data)
    data.each do |key1,value1|
	#@html<<value1['cos_cname']<<value1['cos_ename']<<value1['teacher']<<"<br>"
			@dept=Department.find_by_real_id(value1['dep_id'])
			next if @dept.nil?
			dept_id=@dept.id
			teacher=save_teacher(value1['teacher'],dept_id)
			course=save_course(value1['cos_code'],value1['cos_cname'],value1['cos_ename'],dept_id)
			@cts=save_course_teacher(teacher.id,course.id)
			save_course_teacher_rating(@cts.id)
			save_course_detail(@cts.id,sem_id,value1)
			save_sem_courseship(sem_id,course.id)
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
	@sem= Semester.find_by_real_id(year+sem)
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
    year=(98..103)
		semester=(1..2)
		name=['上','下']
		year.each do |y|
			semester.each do |s|
				sem=Semester.new(:real_id=>y.to_s+s.to_s)
				sem.name=y.to_s+name[s-1]
				sem.save
			end
		end
  end
  def save_course_detail(cts_id,sem_id,raw_data)
    @cd=CourseDetail.where(:course_teachership_id=>cts_id, :semester_id=>sem_id).take
    if @cd.nil?
	  #@department
			@cd=CourseDetail.new
			@cd.course_teachership_id=cts_id
			@cd.semester_id=sem_id
			@cd.credit=raw_data['cos_credit']
			@cd.time=raw_data['cos_time'].partition('-')[0]
			@cd.room=raw_data['cos_time'].partition('-')[2]
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
    @dept_real_id=[]
	Department.all.each do |dept|
	@dept_real_id.append(dept.degree+dept.real_id)
	end
	
	@slice=21
	
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
  def parse_dep
    @type=[3,2,0]#,7,72,8] 
	
    data=Array.new
    @type.each do |_type|
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
