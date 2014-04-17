class FilesController < ApplicationController
  include ApplicationHelper
  
  def all_users
    @courses=Course.all
	@files=FileInfo.new
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
     @file_info = FileInfo.new
     #render :file => 'app/views/upload/uploadfile.html.erb'
  end
  
  def create
	  #owner_id=params[:file_info][:owner_id]
	if request.post?
	  course_id=params[:file_info][:course_id]
	  params[:file_info][:path].each do |file|
		name = file.original_filename
		directory = "./data_upload/"<<Course.find(course_id).eng_name<<'/'
		if !File.directory?(directory)
		
		  Dir.mkdir(directory, 0700)
		end
		path = File.join(directory, name)
		if !File.exist?(path)
			file_data=File.open(path, "wb") { |f| f.write(file.read) }		
			@file_info=FileInfo.new
			@file_info.owner_id=current_user.id
			@file_info.course_id=course_id
			@file_info.name=file.original_filename
			@file_info.size=File.size(path)
			@file_info.save!		
			@message="上傳成功!"#<<"</div>"div_notice<<
			#@message=@message#.html_safe
		else
			@message="檔案已存在!"
		end
		#flash[:notice] = @message
		
	  end
	  #respond_to do |format|
	#	format.json  { render :json => :message=>@message }
	 # end
	   #render @message
	  #redirect_to :action =>"upload" 
	end
	
	#name = params[:data_file][:path].original_filename
	#directory = "./data_upload/"
    #path = File.join(directory, name)
    #File.open(path, "wb") { |f| f.write(params[:data_file][:path].read) }
    #flash[:notice] = "File uploaded"
   
  end
  
  def download
    @file=FileInfo.find(params[:id])
	@path=File.join(Course.find(@file.course_id).eng_name,@file.name)
    send_file Rails.root.join('data_upload', @path), :x_sendfile=>true
  end

  def delete
    @file=FileInfo.find(params[:id])
	@dir="./data_upload/"
	@dir<<Course.find(@file.course_id).eng_name<<'/'
	@name=File.join(@dir,@file.name)
	if File.exist?(@name)
	  File.delete(@name)
	end
	@file.destroy!
	redirect_to :action => :index
  end
  
  
  private
  def dat_params
    params.require(:data_file).permit(:content, :course_id)
  end
  
  
end
