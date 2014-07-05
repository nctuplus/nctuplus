class FilesController < ApplicationController
  include ApplicationHelper
  before_filter :checkOwner,  only: [:edit, :delete_file]
  
  def show
    @upload = FileInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @upload }
    end
  end
  
  def all_users
    @courses=Course.all
	#@files=FileInfo.all
  end
  
  def one_user
    @files=FileInfo.where(:owner_id=>current_user.id)
	#@files=FileInfo.new
  end
  
  def edit
    @file=FileInfo.find(params[:_id])
	@file.description=params[:_content]
	@file.save!
	respond_to do |format|
	  format.js{}
	end
    #params[:file_info]
     #@file_info = FileInfo.new
     #render :file => 'app/views/upload/uploadfile.html.erb'
  end
  def upload
    #id
     @file_info = FileInfo.new
     #render :file => 'app/views/upload/uploadfile.html.erb'
  end
  
  # def create
	  # #owner_id=params[:file_info][:owner_id]
	  # course_id=params[:file_info][:course_id]
	  # params[:file_info][:path].each do |file|
		# name = file.original_filename
		# directory = "./data_upload/"<<Course.find(course_id).eng_name<<'/'
		# if !File.directory?(directory)	
		  # Dir.mkdir(directory, 0700)
		# end
		# path = File.join(directory, name)
		# if !File.exist?(path)
			# file_data=File.open(path, "wb") { |f| f.write(file.read) }		
			# @file_info=FileInfo.new
			# @file_info.owner_id=current_user.id
			# @file_info.course_id=course_id
			# @file_info.name=file.original_filename
			# @file_info.size=File.size(path)
			# if @file_info.save
			  # respond_to do |format|
				# format.html {
				  # j(render :partial => "show_cell", :locals=>{:file=>@file_info, :user_name=>"no", :course_name=>"no", :action=>"edit"})

				# }
			  # end
			# end			
		# else
			# @message="檔案已存在!"
		# end
		# #flash[:notice] = @message
	  # end
	
  # end
  def create
    @upload = FileInfo.new(data_params)

    respond_to do |format|
      if @upload.save
        format.html {
          render :json => [@upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@upload.to_jq_upload]}, status: :created, location: @upload }
      else
        format.html { render action: "new" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end
  def download
    @file=FileInfo.find(params[:id])
	@path=File.join(Course.find(@file.course_id).eng_name,@file.name)
    send_file Rails.root.join('data_upload', @path), :x_sendfile=>true
  end

  def delete_file

	@file=FileInfo.find_by_id(params[:id]) #don't know why find raises null
	if @file
	  @dir="./data_upload/"
	  @dir<<Course.find(@file.course_id).eng_name<<'/'
	  @name=File.join(@dir,@file.name)
	  if File.exist?(@name)
	    File.delete(@name)
	  end
	  @file.destroy!
	end
	redirect_to :action => :all_users
	#redirect_to :root_url
  end
  
  
  private
  def data_params
    params.require(:file_info).permit(:upload)
  end
  
  
end
