class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
  
	layout false, :only => [:list_all_courses, :search_by_keyword, :search_by_dept]
	
	
	before_filter :checkLogin, :only=>[ :rate_cts]
	
	def index

		@semesters=Semester.all
		

		@departments=Department.where(:viewable=>'1')
		@departments_all_select=@departments.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_grad_select=@departments.select{|d|d.degree=='2'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_under_grad_select=@departments.select{|d|d.degree=='3'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_common_select=@departments.select{|d|d.degree=='0'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		
		@degree_select=[{"walue"=>'3', "label"=>"大學部[U]"},{"walue"=>'2', "label"=>"研究所[G]"},{"walue"=>'0', "label"=>"大學部共同課程[C]"}].to_json
		
		@semester_select=Semester.all.select{|s|s.courses.count>0}.map{|s| {"walue"=>s.id, "label"=>s.name}}.to_json
	
  end
	
	def list_all_courses
	  page=params[:page].to_i
		id_begin=(page-1)*each_page_show
		@course_details=CourseDetail.where(:id=>id_begin..id_begin+each_page_show)
		@course_details=@course_details.sort_by{|cd| cd.course_teachership.course_teacher_ratings.sum(:avg_score)}.reverse
		#@course_details=@courses
		@page_numbers=CourseDetail.all.count/each_page_show
	  render "course_lists"
	end
	
	def search_by_dept
		dept_id=params[:dept_id]
		semester_id=params[:sem_id].to_i
		
		dept_ids=get_dept_ids(dept_id)
		
		semester=Semester.find(semester_id)
		@courses=semester.courses.select{|c| join_dept(c,dept_ids)}
		@course_details=join_course_detail(@courses,semester_id)
		
		@page_numbers=1#@course_details.count/each_page_show
		render "course_lists"
	end
	
	  def search_by_keyword
	  search_term=params[:search_term]
		search_type=params[:search_type]
		semester_id=params[:sem_id].to_i
		dept_id=params[:dept_id]
		dept_ids= get_dept_ids(dept_id)
		case search_type
			when "course_no"
				if !semester_id.nil?
					@courses= Course.where(" id IN (:id) AND real_id LIKE :real_id ",
							{ :id=>SemesterCourseship.select("course_id").where(:semester_id=> semester_id), :real_id => "%#{search_term}%" })	
				else
					@courses= Course.where("real_id LIKE :real_id ",
																{:real_id => "%#{search_term}%" })#, :id=> SemesterCourseship.select("course_id").where(:semester_id=> "8"))		
				end
				@courses=@courses.select{|c| join_dept(c,dept_ids) } if dept_ids
				
			when "course_name"
				if !semester_id.nil?
					@courses = Course.where("id IN (:id) AND ch_name LIKE :name ",
						{:id=>SemesterCourseship.select("course_id").where(:semester_id=> semester_id), :name => "%#{search_term}%" })
				else
					@courses= Course.where("ch_name LIKE :name ",
																{:name => "%#{search_term}%" })#, :id=> SemesterCourseship.select("course_id").where(:semester_id=> "8"))		
				end
				@courses=@courses.select{|c| join_dept(c,dept_ids) } if dept_ids
		end
		@course_details=join_course_detail(@courses,semester_id)
		@page_numbers=1#@course_details.count/each_page_show
		render "course_lists"
	end
	
	def rate_cts
    ctr_id=params[:ctr_id].to_i
		score=params[:score].to_i

		@ctr=CourseTeacherRating.find(ctr_id)#:course_teachership_id =>ctr_id, :rating_type=>type).take
		EachCourseTeacherRating.create(:score=>score, :user_id=>current_user.id, :course_teacher_rating_id=>@ctr.id)
		total_rating_counts=EachCourseTeacherRating.where(:course_teacher_rating_id=>@ctr.id).count
		total_rating_sum=EachCourseTeacherRating.where(:course_teacher_rating_id=>@ctr.id).sum(:score)
		@ctr.update_attributes(:total_rating_counts=>total_rating_counts, :avg_score=>total_rating_sum.to_f/total_rating_counts)
		
		result={:new_score=>@ctr.avg_score, :new_counts=>@ctr.total_rating_counts}
		respond_to do |format|
			format.html {
				render :json => result.to_json,
							 :content_type => 'text/html',
							 :layout => false
			}
		end
	end
	
  def show
    @course = Course.find(params[:id])
		@posts = @course.posts
		@post= Post.new #for create course form
		@files=@course.file_infos
		#course_details_tids=CourseDetail.where(:course_id=>@course.id).uniq.pluck(:teacher_id)
		@teachers=@course.teachers#Teacher.where(:id=>course_details_tids)
		@sems=@course.semesters
	#@teachers=Teacher.where(:course_id=>@course.id)
  end
	
  def new
    @course=@department.courses.build
  end
	
  #def create
  #  @course = Course.new(course_param)
  #  @course.save
  #  redirect_to :action => :index
  #end
	
  def edit
    @course = Course.find(params[:id])
  end
	
  def update
    @course = Course.find(params[:id])
	
    @course.ch_name=params[:course][:ch_name]
		@course.eng_name=params[:course][:eng_name]
    @course.save!
    redirect_to :action => :show, :id => @course
  end
	
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    redirect_to :action => :index
  end
  
  protected
  def find_department
    @department=Department.find(params[:department_id])
  end
  
  
  private
	def join_course_detail(courses,semester_id)
		course_ids=courses.map{|c| c.id}
		ct_ids=CourseTeachership.where(:course_id=>course_ids)#@courses.map{|c|c.course_teacherships.map{|ct| ct.id}}
		course_details=CourseDetail.where(:course_teachership_id=>ct_ids).flit_semester(semester_id)
		return course_details
	end
	
	def get_dept_ids(dept_id)
	  return nil if dept_id==""
		
	  dept_ids=[]
		dept_main=Department.find(dept_id)
		dept_ids.append(dept_main.id)
		dept_college=Department.where("degree = #{dept_main.degree} AND viewable = '1' AND real_id LIKE :real_id",{:real_id=>"#{dept_main.college.real_id}%"}).take
		dept_ids.append(dept_college.id) if !dept_college.nil?
		return dept_ids
	end
	
	def join_dept(course,dept_ids)
		dept_ids.each do |dept_id|
		  return true if course.department_id==dept_id
		end
		return false
	end
	
	def each_page_show
	  30
	end
	
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
end
