class MainController < ApplicationController

 	def index
		if current_user && (current_user.year==0 || current_user.department.nil?)
			alertmesg('info','warning', "請填寫系級" )
			redirect_to "/user/edit"
		end
  end

	def get_specified_classroom_schedule
  	if params[:token_id]=="ems5566"
  		@data = CourseDetail.where(:semester_id=>Semester::LAST.id, :room=>params[:room]).includes(:course)	
  		respond_to do |format|
   	 		format.json { render :layout => false, :text => @data.map{|d| [d.course.ch_name, d.time, d.reg_num] }.to_json }
    	end
    end
  end	
  	
	def member_intro
		
	end
  
end
