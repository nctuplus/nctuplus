class FileInfosController < ApplicationController
  # GET /files
  # GET /files.json
  layout false, :only =>[:list_by_ct, :index]
  
  before_filter :checkE3Login, :only=>[:show, :new, :edit, :update, :create, :destroy, :one_user]
  before_filter :checkOwner, :only=>[:edit, :destroy]
	def index
		if params[:ct_id]
			@files = FileInfo.where(:course_teachership_id=>params[:ct_id]).order("download_times DESC")
		else
			@files = FileInfo.where(:owner_id=>current_user.id)#.select(:file
		end
		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @files.map{|file| file.to_jq_upload(current_user) } }
		end
  end
  
	def list_by_ct
		@ct_id=params[:ct_id]
		sem_ids=CourseDetail.select(:semester_id).where(:course_teachership_id=>@ct_id).pluck(:semester_id)
		@sems=Semester.where(:id=>sem_ids).order("id DESC")
		#@course=Course.find(params[:cid])
		#@teacher=Teacher.find(params[:tid])
		#@files=@course.file_infos
		
	end
  
  
  # GET /files/1
  # GET /files/1.json
  def show
    @file = FileInfo.find(params[:id])
		@file.download_times+=1
		@file.save
		send_file @file.download_url#, :type => @file.document_content_type, :disposition => 'inline'
		#respond_to do |format|
		#	format.html # show.html.erb
    #  format.json { render json: @file }
    #end
  end

  # GET /files/new
  # GET /files/new.json
  def new
    @file = FileInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @file }
    end
  end



  # POST /files
  # POST /files.json
  def create
    return if data_params[:course_teachership_id]==""||data_params[:semester_id]==""||data_params[:upload]==""
    
	@file_same=FileInfo.where(:owner_id=>current_user.id,:course_teachership_id=>data_params[:course_teachership_id], :upload_file_name=>data_params[:upload].original_filename).take
	@file_same.destroy! if @file_same
	@file = FileInfo.new(data_params)

		@file.download_times=0
	#@file.course_id=5
	@file.owner_id=current_user.id
	
    respond_to do |format|
      if @file.save
        format.html {
          render :json => [@file.to_jq_upload(current_user)].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@file.to_jq_upload(current_user)]}, status: :created, location: @file }
      else
        format.html { render action: "new" }
        format.json { render json: @file.errors, status: :unprocessable_entity }
      end
    end
  end

	
  def edit
    @file=FileInfo.find(params[:id])
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
    @file = FileInfo.find(params[:id])
		#if @file.owner_id==current_user.id
		#	
		#end
		@file.destroy
    respond_to do |format|
      format.html { redirect_to file_infos_url }
      format.json { head :no_content }
    end
  end
  
  def one_user
    @files=FileInfo.where(:owner_id=>current_user.id)
  end
  
	
	
  private
  def data_params
    #if params[:file_info]
      params.require(:file_info).permit(:upload, :course_teachership_id, :semester_id, :description)
	#end
  end
  
end
