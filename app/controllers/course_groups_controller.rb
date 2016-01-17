class CourseGroupsController < ApplicationController

	before_filter :require_xhr
	before_filter :require_login
	
	def get_list
		cg = CourseGroup.find(params[:id])
		respond_to do |format|
			format.json {render :json=> cg.get_info_for_cm }
		end
	end

	def delete_course
		CourseGroupList.find(params[:id]).destroy
		head :no_content
	end
	
	def setleader

		CourseGroup.find(params[:id]).course_group_lists
		.reject{|l| l.id==params[:leader_id]}.each do |c|
			c.lead = 0
			c.save!
		end
		CourseGroupList.find(params[:leader_id])
		.update_attributes(:lead=>1)

		head :no_content
	end

	def gtype_change 
		cg = CourseGroup.find(params[:id])
		cg.update_attributes(:gtype=> ((cg.gtype==0) ? 1 : 0) )
		head :no_content
	end
	
	def destroy 
		cg = CourseGroup.find(params[:id])	
		CourseField.where(:course_group_id=>cg.id).destroy_all	
		cg.destroy
		head :no_content
	end
	
	def create
		cg = CourseGroup.create(:user_id=> current_user.id, :course_map_id=>params[:cm_id])	
		render :layout=>false, :text=> cg.id
	end

	private
	
	def require_xhr
		unless request.xhr?		
			render :nothing=>true
			return false
		end
	end
	
	def require_login
		unless current_user
			render :nothing=>true
			return false
		end
	end

end