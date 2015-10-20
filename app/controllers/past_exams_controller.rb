class PastExamsController < ApplicationController
  # GET /files
  # GET /files.json
  layout false, :only =>[:course_page]
	
  before_filter :checkLogin, :only=>[:upload]
  before_filter :checkE3Login, :only=>[:show, :new, :update, :create, :destroy, :one_user]
  before_filter :checkOwner, :only=>[:update, :destroy]
	
	def index	#get by ct_id
		@q = PastExam.search_by_text(params[:custom_search])
		@exams=@q.result(distinct: true).includes(:course_teachership).page(params[:page]).order("download_times DESC")
		
  end
	
	def list_by_ct	
		if !params[:ct_id].blank?
			@files = PastExam.where(:course_teachership_id=>params[:ct_id]).order("download_times DESC")
		end
		respond_to do |format|
			format.json { render json: @files.map{|file| file.to_jq_upload(current_user) } }
		end
  end
  
	def course_page
		@ct_id=params[:ct_id]
		@sems=CourseTeachership.find(@ct_id).semesters
	end
  

  def show	#download file
    @file = PastExam.find(params[:id])
		@file.download_times+=1
		@file.save
		send_file @file.download_url
		
  end

	def upload
		@q=CourseTeachership.search(params[:q])
		@ct_id=1
		@sems=Semester.all
	end
  def new
    @file = PastExam.new
    respond_to do |format|
      format.json { render json: @file }
    end
  end



  def create	#upload file
    #return if data_params[:course_teachership_id]==""||data_params[:semester_id]==""||data_params[:upload]==""
    
		#check file exists or not
		file_same=PastExam.where(:user_id=>current_user.id,:course_teachership_id=>data_params[:course_teachership_id], :upload_file_name=>data_params[:upload].original_filename).take	
		return if file_same
		
		@file = PastExam.new(data_params)
		@file.download_times=0
		@file.user_id=current_user.id
		respond_to do |format|
			if @file.save
				format.json { render json: {files: [@file.to_jq_upload(current_user)]}, status: :created, location: @file }
			else
				format.json { render json: @file.errors, status: :unprocessable_entity }
			end
		end

			
  end

	
  def update
    @file=PastExam.find(params[:id])
		#if @file.owner_id==current_user.id
		@file.description=params[:description]
		@file.semester_id=params[:semester_id]
		@file.save!
		#end
		respond_to do |format|
			 format.html {
						render :json => [@file.to_jq_upload(current_user)].to_json,
						:content_type => 'text/html',
						:layout => false
					}
		end

  end
  
  # DELETE /files/1
  # DELETE /files/1.json
  def destroy
    @file = PastExam.find(params[:id])
		@file.destroy
    respond_to do |format|
      format.html { redirect_to file_infos_url }
      format.json { head :no_content }
    end
  end
  
	
  private
  def data_params
    params.require(:past_exam).permit(:upload, :course_teachership_id, :semester_id, :description, :is_anonymous)
  end
  
end
