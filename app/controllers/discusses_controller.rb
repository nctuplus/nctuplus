class DiscussesController < ApplicationController
	# 
	#layout false, :only =>[:list_by_course]
	before_filter :checkLogin, :only=>[:new, :update, :like, :create, :update, :delete]
	#before_filter :checkOwner, :only=>[:update, :delete]


	def index
		@q = Discuss.search_by_text(params[:custom_search])
		@discusses=@q.result(distinct: true).includes(:course_teachership).page(params[:page]).order("id DESC")	
		@ct=CourseTeachership.find(1)
	end

	def like
		@like=current_user.discuss_likes.create(:like=>params[:like])
		
		case params[:type] 
			when "main"
				@like.discuss_id=params[:discuss_id]
				@discuss=Discuss.find(params[:discuss_id])
				unless @discuss.discuss_likes.select{|l|l.user_id==current_user.id}.empty?
					render :nothing => true, :status => 400, :content_type => 'text/html'
					return
				end
			when "sub"
				@like.sub_discuss_id=params[:discuss_id]
				@discuss=SubDiscuss.find(params[:discuss_id])
				unless @discuss.discuss_likes.select{|l|l.user_id==current_user.id}.empty?
					render :nothing => true, :status => 400, :content_type => 'text/html'
					return
				end
			else 
				return
		end
		@like.save!
		if @like.like
			@discuss.likes+=1
			@discuss.save!
		else
			@discuss.dislikes+=1
			@discuss.save!
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'	
		
	end
    
    
	def show
		#@ct_id=
		@ct=CourseTeachership.includes(:course).find(params[:ct_id].to_i)
		@discusses=@ct.discusses.includes(:sub_discusses, :user, :discuss_likes).order("updated_at DESC")
		render :layout=>false
	end
	
	
	

	
	def update	
		if params[:type]=="main"
			@discuss=Discuss.find(params[:id])
			@discuss.content=params[:content]
			@discuss.title=params[:title]			
			@discuss.save!
		elsif params[:type]=="sub"
			@discuss=SubDiscuss.find(params[:id])
			@discuss.content=params[:content]
			@discuss.save!
		end
		redirect_to :action=> :show, :ct_id=>params[:ct_id]
	end
	
	def delete
		if params[:type]=="main"
			@discuss=Discuss.find(params[:id])
		elsif params[:type]=="sub"
			@discuss=SubDiscuss.find(params[:id])
		end
		@discuss.destroy!
		redirect_to :action=> :show, :ct_id=>params[:ct_id]
	end
    

	def new
		@discuss = Discuss.new
		@q=CourseTeachership.search(params[:q])
	end
    
	def create        
		#@discuss=Discuss.create(event_params.merge({:user_id=>current_user.id, :course_teachership_id=>123, :likes=>0, :dislikes=>0}))
		#@discuss=Discuss.create(discuss_params.merge({:user_id=>current_user.id, :likes=>0, :dislikes=>0}))
	
		if params[:type].blank?
			@discuss=current_user.discusses.create(main_discuss_params.merge({:likes=>0,:dislikes=>0}))
=begin
			@discuss=current_user.discusses.create(
				:course_teachership_id=>params[:ct_id],
				:user_id=>current_user.id,
				:likes=>0,
				:dislikes=>0,
				:title=>params[:title],
				:content=>params[:content],
				:is_anonymous=>params[:anonymous]=="yes"
			)
=end
		elsif params[:type]=="sub"
			@discuss=current_user.sub_discusses.create(sub_discuss_params.merge({:likes=>0,:dislikes=>0}))
=begin			
			@discuss=SubDiscuss.create(
				:discuss_id=>params[:reply_discuss_id],
				:user_id=>current_user.id,
				:likes=>0,
				:dislikes=>0,
				:content=>params[:content]
			)
=end
		end
		if !request.xhr?
			redirect_to :action => :index
		end	
	end

	private

	def main_discuss_params
		params.require(:discuss).permit(:title, :content, :is_anonymous, :course_teachership_id)
	end
	def sub_discuss_params
		params.require(:sub_discuss).permit(:content, :discuss_id)
	end
end
