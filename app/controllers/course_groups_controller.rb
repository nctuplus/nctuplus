class CourseGroupsController < ApplicationController
	def index
		@course_groups=CourseGroup.all
	end
	def show
		@course_group=CourseGroup.find(params[:id])
	end
	def new
		@course_group=CourseGroup.new
		render "_form"
	end
	def create
		@course_group = CourseGroup.create(course_group_param)

    redirect_to :action => :index
	end
	
	def edit
		@course_group=CourseGroup.find(params[:id])
		render "_form"
	end
	def update
		@course_group=CourseGroup.find(params[:id])
		@course_group.update_attributes(course_group_param)

    redirect_to :action => :index
	end
	
	def add_list
		@cg_list=CourseGroupList.new
		@cg_list.course_group_id=params[:cg_id]
		@cg_list.semester_id=params[:sem_id]
		@cg_list.course_type=""
		@cg_list.user_id=current_user.id
	end
	private
	
  def course_group_param 
		params.require(:course_group).permit(:title, :description, :department_id)
  end
	
end
