class CoursesController < ApplicationController
  before_filter :find_department, :only=>[ :index, :new, :edit]
  
  def index
    @courses=@department.courses
  end
  def show
    @course = Course.find(params[:id])
	@posts = @course.posts
	@post= Post.new #for create course form
	@files=@course.file_infos
	@teachers=@course.teachers
	@sems=@course.semesters
	#@teachers=Teacher.where(:course_id=>@course.id)
  end
  def new
    #@department=Department.find(params[:department_id])
    @course=@department.courses.build
	
  end
  def create
    @course = Course.new(course_param)
    @course.save
	#newdir="./data_upload/"<<@course.eng_name
    #Dir.mkdir newdir
    redirect_to :action => :index
  end
  def edit
    #@department=Department.find(params[:department_id])
    @course = Course.find(params[:id])
	#redirect_to :action => :index 
  end
  def update
    @course = Course.find(params[:id])
	
    @course.ch_name=params[:course][:ch_name]
	@course.eng_name=params[:course][:eng_name]
	#update_attributes()
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
  def course_param
    
	params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
end
