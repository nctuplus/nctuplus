class PostController < ApplicationController
  #require 'coderay'

  before_filter :checkOwner,  only: [:edit, :update, :destroy]
  #before_filter :checkCourseManager,  only: [:edit, :update, :destroy]
  #def getcode
   #coderay = CodeRay.scan(params[:code], params[:lang]).div(:line_numbers => :table)
  # 
  # render json: { code: coderay }.to_json
  #end
  def index
    @posts=Post.all.order("updated_at DESC");
	#@posts
  end
  def show
    @post = Post.find(params[:id])
  end
  def new
    @post=Post.new
	@action="create"
	render :_form
  end
  def create
    @post = Post.new(post_param)
	@post.owner_id=current_user.id
    @post.save!
	
	handle_tag(@post)

	redirect_to :action => :index
    #redirect_to :controller=>:course, :action => :show, :id=>params[:id]
  end
  def edit
    @post = Post.find(params[:id])
	@tags = ""
	@post.courses.each do |tag|
	  @tags<<tag.eng_name<<','
	end
	@action="update"
	render :_form
  end
  def update
    @post = Post.find(params[:id])
	@post.content = params[:post][:content]
	@post.title = params[:post][:title]

	handle_tag(@post)	
	@post.save!

    redirect_to :action => :show, :id => @post.id
  end
  def destroy
    @post = Post.find(params[:id])

    @post.destroy
	
    redirect_to :action => :index
  end
  
  private
  
  def handle_tag(post)
    tagslist=params[:post][:tags].gsub(" ",'').split(",")
	
	CoursePostship.destroy_all(:post_id=>post.id) unless post.new_record?

	CoursePostship._create(post.id,tagslist)
  end
  
  def post_param
    
	params.require(:post).permit(:title, :content)
  end
  
end