class FilesController < ApplicationController
  def index
    @courses=Course.all
	
  end
  def upload
     @file_info = FileInfo.new
     #render :file => 'app/views/upload/uploadfile.html.erb'
  end
  
  def create
	  #owner_id=params[:file_info][:owner_id]
	  course_id=params[:file_info][:course_id]
	params[:file_info][:path].each do |file|
		name = file.original_filename
		directory = "./data_upload/"<<Course.find(course_id).eng_name<<'/'
		path = File.join(directory, name)
		file_data=File.open(path, "wb") { |f| f.write(file.read) }
		flash[:notice] = "File uploaded"
		
		@file_info=FileInfo.new
		@file_info.owner_id=current_user.id
		@file_info.course_id=course_id
		@file_info.name=file.original_filename
		@file_info.size=File.size(path)
		@file_info.save!
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

  def pdf
    send_file Rails.root.join('private', 'Rogelio Alvarado Vilchis.pdf'), :type=>"application/pdf", :x_sendfile=>true
  end

  def doc
    send_file Rails.root.join('private', 'Rogelio Alvarado Vilchis.docx'), :type=>"application/doc", :x_sendfile=>true
  end
  
  
  private
  def dat_params
    params.require(:data_file).permit(:content, :course_id)
  end
  
  
end
