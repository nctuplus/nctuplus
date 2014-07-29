class DepartmentsController < ApplicationController
  before_filter :checkTopManager
  def index
    @departments=Department.all
	
  end
  def show
    @department = Department.find(params[:id])
	@courses = @department.courses
	@teachers = @department.teachers
	
  end
  def new
    @department=Department.new
  end
  def create
    @department = Department.new(department_param)
    @department.save
	#newdir="./data_upload/"<<@department.eng_name
    #Dir.mkdir newdir
    redirect_to :action => :index
  end
  def edit
    
    @department = Department.find(params[:id])
  end
  def update
    @department = Department.find(params[:id])
    @department.update_attributes(department_param)
  
    redirect_to :action => :index
  end
  def destroy
    @department = Department.find(params[:id])
    @department.destroy

    redirect_to :action => :index
  end
  
  private
  def department_param
    
	params.require(:department).permit(:ch_name, :credit, :dept_type)
  end
  
end
