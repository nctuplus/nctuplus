class PostController < ApplicationController
  #require 'coderay'
  #def show_bycourse
  #  @course=Course.find(params[:id])
#	@posts=@course.posts
#  end
  before_filter :checkOwner,  only: [:edit, :update, :destroy]
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
    @post.save
	@tagslist=params[:post][:tags].split(", ")
	CoursePostship._create(@post.id,@tagslist,"zzz")
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
	@post.save!
	
	CoursePostship._destroy_by_postid(params[:id])
	
	@tagslist=params[:post][:tags].split(", ")
	CoursePostship._create(params[:id],@tagslist,"zzz")
	
    #@post.update_attributes()
  
    redirect_to :action => :show, :id => @post.id
  end
  def destroy
    @post = Post.find(params[:id])

    @post.destroy
	
    redirect_to :action => :index
  end
  
  private
  def post_param
    
	params.require(:post).permit(:title, :content)
  end
  
end
