class TeachersController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
  def index
    @teachers=Teacher.all
	
  end
  def show
    @teacher = Teacher.find(params[:id])
	#@courses = @teacher.courses
  end
  def new
    #@teacher=@department.teachers.build
    @department=Department.find(params[:department_id])
    @teacher=Teacher.new
	
  end
  def create
    @teacher = Teacher.new(teacher_param)
    @teacher.save
	#newdir="./data_upload/"<<@teacher.eng_name
    #Dir.mkdir newdir
    redirect_to :controller=>:departments , :action => :show, :id=>params[:teacher][:department_id]
  end
  def edit
    @department = Department.find(params[:department_id])
    @teacher = Teacher.find(params[:id])
  end
  def update
    @teacher = Teacher.find(params[:id])
	@teacher.update(:name=>params[:teacher][:name])
	
    #@teacher.update_attributes(params[:teacher])
  
    redirect_to :controller=>:departments , :action => :show, :id=>params[:teacher][:department_id]
  end
  def destroy
    @teacher = Teacher.find(params[:id])
    @teacher.destroy

    #redirect_to :controller=>:departments , :action => :show, :id=>params[:teacher][:department_id]
  end
  
  #protected
  #def find_department
  #  @department=Department.find(params[:department_id])
  #end
  
  private
  def teacher_param
    
	params.require(:teacher).permit(:name, :department_id)
  end
  
end
