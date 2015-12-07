class PastExamsController < ApplicationController
  # GET /files
  # GET /files.json
  
  before_filter :checkLogin, :only=>[:upload, :new, :update, :create, :destroy]
  before_filter :checkE3Login, :only=>[:show]

	def index	#get by ct_id
		if current_user && params[:mine]=="true"
			@q=PastExam.search({:user_id_eq=>current_user.id})
		else
			@q = PastExam.search_by_q_and_text(params[:q],params[:custom_search])
		end
		@recent=PastExam.includes(:user,:course_teachership, :course).order("created_at DESC").take(10).map{|exam|{
			:url=>exam.upload.url(:original),
			:ct_name=>"#{exam.course.ch_name}",#/#{exam.course_teachership.teacher_name}",
			:user_name=>exam.owner_name,
			:time=>exam.created_at,
			:name=>exam.upload_file_name			
		}}

		@exams=@q.result(distinct: true).includes(:user,:course_teachership, :course).page(params[:page]).order("download_times DESC")
		
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
		render :layout=>false
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
    @file=current_user.past_exams.find(params[:id])
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
    @file = current_user.past_exams.find(params[:id])
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
