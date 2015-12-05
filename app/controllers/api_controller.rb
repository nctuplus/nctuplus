class ApiController < ApplicationController
	before_filter :cors_set_access_control_headers, :only=>[:query_from_time_table, :query_from_cos_adm, :import_course]
	skip_before_filter :verify_authenticity_token, :only=>[:import_course]
	def login
		config=AndroidApp::KEY
		if params[:key]!=config
			data={
				:auth=>false
			}
		else
			data = AuthE3.from_omniauth(params[:username], params[:password], nil)
			if data[:user].hasFb?
				data[:uid]=data[:user].uid
			end
		end
		
		respond_to do |format|
      format.html do
        render :json => data
      end
    end
		#render "/main/gg88"
	end
	def import_course
		result = AuthE3.from_omniauth(params[:username], params[:password], nil)
		if result[:auth]
			user=result[:user]
			user.normal_scores.joins(:course_detail).where("course_details.semester_id = ?",Semester::LAST.id).readonly(false).destroy_all
			cds=CourseDetail.select(:id).where(:temp_cos_id=>params[:cos_ids])
			user.normal_scores.create(
				cds.map{|cd|{
					:course_detail_id=>cd.id,
					:score=>"修習中"
				}}
			)
			count=user.normal_scores.joins(:course_detail).where("course_details.semester_id = ?",Semester::LAST.id).count
			status=true
		else
			status=false
			count=0
		end
		respond_to do |format|
      format.html do
        render :json => {
					:status=>status,
					:count=>count
				}
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
