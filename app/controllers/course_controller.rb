class CourseController < ApplicationController
  def index
    @courses=Course.all
	
  end
  def show
    @course = Course.find(params[:id])
  end
  def new
    @course=Course.new
  end
  def create
    @course = Course.new(course_param)
    @course.save
	newdir="./data_upload/"<<@course.eng_name
    Dir.mkdir newdir
    redirect_to :action => :index
  end
  def edit
    @course = Course.find(params[:id])
  end
  def update
    @course = Course.find(params[:id])
    @course.update_attributes(params[:course])
  
    redirect_to :action => :show, :id => @course
  end
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    redirect_to :action => :index
  end
  
  private
  def course_param
    
	params.require(:course).permit(:ch_name, :eng_name, :grade_id)
  end
  
end
