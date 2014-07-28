class ReviewsController < ApplicationController
	before_filter :checkTopManager, :only=>[:update, :destroy]
	
	layout false, :only => [:list_all_reviews, :search_by_keyword]

	def index
		@reviews=Review.all
		@view_type="all"
		@page=1
	end
	
	def show
		@review=Review.find(params[:id])
		#@courses_all_select=Course.all.map{|c| {"walue"=>c.id, "label"=>c.ch_name}}.to_json
		#if @review.course_id
		#	@course_name=@review.course.ch_name
		#else
		#	@course_name=""
		#end
	end
	def search_by_keyword
		@search_term=params[:search_term]
		@search_type=params[:search_type]
		
		@page=params[:page].to_i
		id_begin=(@page-1)*each_page_show
		if @search_type=="title"||@search_type=="content"
			@reviews_all=Review.where("#{@search_type} LIKE ?  ","%#{@search_term}%").order("date DESC")#.limit(each_page_show).offset(id_begin)
			@counts=@reviews_all.count
			@reviews=@reviews_all.limit(each_page_show).offset(id_begin)
			@page_numbers=@counts/each_page_show
			render "review_lists"
		end
	end
	def list_all_reviews
	  @page=params[:page].to_i
		id_begin=(@page-1)*each_page_show
		@reviews=Review.order("date DESC").limit(each_page_show).offset(id_begin)
		#@reviews=@course_details.sort_by{|cd| cd.course_teachership.course_teacher_ratings.sum(:avg_score)}.reverse
		#@course_details=@courses
		@view_type="all"
		@page_numbers=Review.all.count/each_page_show
	  render "review_lists"
	end
	
	def update
    @review = Review.find(params[:id])
    @review.update_attributes(:course_id=>params[:review][:course_id])
  
    redirect_to :action => :index
  end	
	def destroy
    @review = Review.find(params[:id])
    @review.destroy
		page = params[:page]
    redirect_to :action => :index#, :page=>page
  end
	private
	def each_page_show
		50
	end
end
