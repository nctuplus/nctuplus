class BooksController < ApplicationController
  
	before_filter :checkLogin, :only=>[:new, :create]
	#before_filter :checkE3Login
	
	def cts_search
		@q=CourseTeachership.search(params[:q])
		if request.format=="js"
			@res=@q.result(distinct: true).includes(:course).page(1).map{|cts|{
				:id=>cts.id,
				:course_name=>cts.course_ch_name,
				:teacher_name=>cts.teacher_name
			}}
		else
			@book=Book.find(params[:book_id])
			#@cts_list=@book.course_teachership
		end
	end
	
	def set_cts
		@book=Book.find(params[:book_id])
		params[:cts_id_list].split(",").each do |ct_id|
			@book.book_ctsships.create(:course_teachership_id=>ct_id)
		end
		redirect_to "/main/cts_search?book_id=#{params[:book_id]}"
	end
	
	def book_show
		@book=Book.find(params[:book_id])
	end
	
	def index
		#@books=Book.all
		@sale_books=BookTradeInfo.all
  end
	
  def google_book
		@res = GoogleBooks.search(params[:title],{:count => 5})
		respond_to do |format|
			format.json{render json: @res}
		end
  end
  
  def show
    
  end
  
  def new
    @sale_book = BookTradeInfo.new
		@q=CourseTeachership.search(params[:q])
    #@list = BookTradeInfo.all
  end
  
  def create
    params[:book_trade_info][:user_id]=current_user.id
    @book = BookTradeInfo.new(book_params)
		if @book.valid?
			@book.save!
			redirect_to :action => "new"
		end
    
  end
  
private
	def book_params
		params.require(:book_trade_info).permit(:user_id, :book_name, :image_url, :price, :desc)
	end
 
  
  
end
