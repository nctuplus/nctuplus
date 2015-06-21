class BooksController < ApplicationController
  before_filter :checkTopManager
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
	
	def index
		#@books=Book.all
		
		@q=BookTradeInfo.search_by_q(params[:custom_search])
		@sale_books=@q.result(distinct: true).order("created_at DESC,status ASC")
	end
	
  def google_book
		self_books=Book.ransack({title_cont: params[:title]}).result.map{|book|{
			:title=>book.title,
			:authors=>book.authors,
			:isbn=>book.isbn,
			:description=>book.description,
			:image_link=>book.image_link,
			:preview_link=>book.preview_link
		}}
		@res=self_books
    for i in 1..5
      google_books = GoogleBooks.search(params[:title],{:page => i}).map{|book|{
        :title=>book.title,
        :authors=>book.authors,
        :isbn=>book.isbn,
        :description=>book.description,
        :image_link=>book.image_link,
        :preview_link=>book.preview_link
      }}
      @res+=google_books
		end
    
		respond_to do |format|
			format.json{render json: @res}
		end
  end
  
  def show
    @sale_book=BookTradeInfo.find(params[:id])
		@sale_book.incViewTimes!
		@book=@sale_book.book
  end
  
  def new
		
    @sale_book = BookTradeInfo.new(:contact_way => 0)
    @book = Book.new
		@q=CourseTeachership.search(params[:q])
		render "_form"
  end
	
  def edit
    @sale_book = current_user.book_trade_infos.find(params[:id])
    @book = @sale_book.book
		@q=CourseTeachership.search(params[:q])
		render "_form"
  end
	
	def update	
		@book_trade_info=current_user.book_trade_infos.find(params[:id])
		@book_trade_info.update(
			book_trade_info_params#.merge({:book_id=>@book.id})
		)
		if params[:cts_id_list].present?
			@book_trade_info.book_trade_info_ctsships.destroy_all
			params[:cts_id_list].split(",").uniq.each do |ct_id|
				next if ct_id.blank?
				@book_trade_info.book_trade_info_ctsships.create(:course_teachership_id=>ct_id)
			end
		end
		if request.xhr?
			render :nothing=>true, :status=>200
		else
			redirect_to "/books/"
		end
	end
	
  def create
		if book_params[:id].blank?
			@book=Book.create(book_params.merge({:user_id=>current_user.id}))
		else
			@book=Book.find(book_params[:id])
		end
		@book_trade_info=current_user.book_trade_infos.create(
			book_trade_info_params.merge({:book_id=>@book.id})
		)
		params[:cts_id_list].split(",").uniq.each do |ct_id|
			next if ct_id.blank?
			@book_trade_info.book_trade_info_ctsships.create(:course_teachership_id=>ct_id)
		end
		redirect_to "/books/"
	end
  
private
	
  def book_trade_info_params
    params.require(:book_trade_info).permit(:book_name, :price, :desc, :contact_way, :cover, :status)
  end
	
	def book_params
		params.require(:book).permit(:title, :isbn, :authors, :description, :image_link, :preview_link)
	end
end
