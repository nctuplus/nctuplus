class DiscussesController < ApplicationController
	# 
	#layout false, :only =>[:list_by_course]
	before_filter :checkLogin, :only=>[:new, :update, :like, :create, :update, :delete]
	#before_filter :checkOwner, :only=>[:update, :delete]


	def index
		if current_user && params[:mine]=="true"
			@q=Discuss.search({:user_id_eq=>current_user.id})
		else
			if params[:custom_search]
				@q = Discuss.search_by_text(params[:custom_search])
			else
				@q = Discuss.search(params[:q])
			end
			#@q = Discuss.search_by_text(params[:custom_search])
		end
		main_recent=Discuss.includes(:user,:course_teachership, :course).order("created_at DESC").take(10).map{|discuss|discuss.recent_obj}
		sub_recent=SubDiscuss.includes(:user, :discuss).order("created_at DESC").take(10).map{|sub_d|sub_d.recent_obj}
		@recent=main_recent+sub_recent
		@recent=@recent.sort{ |x, y| y[:time] <=> x[:time] }.first(10) #!{|d|d[:time]}
		@discusses=@q.result(distinct: true).includes(:course_teachership, :sub_discusses, :user).page(params[:page]).order("id DESC")	
		#@ct=CourseTeachership.find(1)
	end
	
	def show
		@discuss=Discuss.includes(:sub_discusses, :course_teachership, :course_details).find(params[:id])
		discuss_id=@discuss.id.to_s
		@result=@discuss.show_obj(current_user.try(:id))
	end

	def new
		@title="新增文章"
		@discuss = Discuss.new	
		@q=CourseTeachership.search(params[:q])
		if params[:ct_id].present?
			@ct=CourseTeachership.find(params[:ct_id])
		end
	#	@imgsrc=current_user.avatar_url
		render "main_form"
	end
	
	def edit	#only for main discuss
		@title="修改文章"
		@discuss=current_user.discusses.find(params[:id])
		@q=CourseTeachership.search(params[:q])
		@ct=@discuss.course_teachership
		@imgsrc=current_user.avatar_url
		render "main_form"
	end
	
	def create        
		if params[:type].blank?
			@discuss=current_user.discusses.create(main_discuss_params)
			
			#涼度 params["discuss"]["cold_rating"]			
			CourseTeacherRating.find_or_create_by(
				user_id: current_user.id, 
				course_teachership_id: main_discuss_params["course_teachership_id"],
				rating_type: 1,
				score: params["discuss"]["cold_rating"]
				)

			#甜度 params["discuss"]["sweety_rating"]
			CourseTeacherRating.find_or_create_by(
				user_id: current_user.id, 
				course_teachership_id: main_discuss_params["course_teachership_id"],
				rating_type: 2,
				score: params["discuss"]["sweety_rating"]
				)

			#深度 params["discuss"]["hardness_rating"]
			CourseTeacherRating.find_or_create_by(
				user_id: current_user.id, 
				course_teachership_id: main_discuss_params["course_teachership_id"],
				rating_type: 3,
				score: params["discuss"]["hardness_rating"]
				)

		elsif params[:type]=="sub"
			@discuss=current_user.sub_discusses.create(sub_discuss_params)
			if  @discuss.discuss.user_id != current_user.id
				InformMailer.discuss_reply(@discuss).deliver#.discuss.user_id
			end
		end
		if !request.xhr?
			redirect_to :action => :index
		end	
	end
	
	def update	
		if params[:type].blank?
			@discuss=current_user.discusses.find(params[:id])
			@discuss.update(main_discuss_params)
			redirect_to :action=> :show, :id=>params[:id]
		elsif params[:type]=="sub"
			@sub_d=current_user.sub_discusses.find(params[:id])
			#@discuss.content=params[:content]
			@sub_d.update(sub_discuss_params)
			#@discuss.save!
			#redirect_to :action=> :show, :id=>@discuss.discuss_id
		end
		
	end
	
	def destroy
		if params[:type].blank?
			@discuss=current_user.discusses.find(params[:id])
			@discuss.destroy!
			redirect_to :action=> :index
		elsif params[:type]=="sub"
			@sub_d=current_user.sub_discusses.find(params[:id])
			#@sub_d_id=@discuss.discuss_id
			@sub_d.destroy!
			#redirect_to :action=> :show, :id=>@discuss_id
		end
		
		
	end
  
	def list_by_ct
		#@ct_id=
		@ct=CourseTeachership.includes(:course).find(params[:ct_id].to_i)
		@discusses=@ct.discusses.includes(:sub_discusses, :user).order("updated_at DESC")
		render :layout=>false
	end
	
	
	private

	def main_discuss_params
		params.require(:discuss).permit(:title, :content, :is_anonymous, :course_teachership_id)
	end
	def sub_discuss_params
		params.require(:sub_discuss).permit(:content, :discuss_id, :is_anonymous)
	end
end
