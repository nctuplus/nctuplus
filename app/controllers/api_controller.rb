class ApiController < ApplicationController
	before_filter :cors_set_access_control_headers, :only=>[:query_from_time_table, :query_from_cos_adm, :import_course]
	
	def import_course
		respond_to do |format|
      format.html do
        render :json => [params[:passwd]]
      end
    end
	end
	def query_from_time_table
		@cds=[]
		params[:cos_id].each_with_index do |cos_id,i|
			cd=CourseDetail.select(:id).where(:temp_cos_id=>cos_id, :semester_id=>params[:sem_id][i]).take
			next if cd.nil?
			@cds.push({:cd_id=>cd.id, :cos_id=>cos_id})
		end

		respond_to do |format|
      format.html do
        render :json => @cds#, :callback => params[:callback]
      end
    end
	end
	
	def query_from_cos_adm
		
		@cds=CourseDetail.select(:id,:temp_cos_id).where(:temp_cos_id=>params[:cos_id],:semester_id=>Semester::LAST.id)
		
		respond_to do |format|
      format.html do
        render :json => @cds.map{|cd|{
					:cd_id=>cd.id,
					:cos_id=>cd.temp_cos_id
				}}
      end
    end
	end
	
	private
	
	def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Max-Age'] = "1728000"
    headers['Access-Control-Allow-Headers'] = 'content-type, accept'
  end
	
	
end
