class BooksController < ApplicationController
  #before_filter :checkTopManager
	before_filter :checkLogin, :only=>[:new, :create, :edit, :update]
	#before_filter :checkNCTULogin

	def index
		if current_user && params[:mine]=="true"
			@q=BookTradeInfo.search({:user_id_eq=>current_user.id})
		else
			@q=BookTradeInfo.search(params[:q])
		end
		@q.sorts = ['status asc', 'created_at desc'] if @q.sorts.empty?	
		@sale_books=@q.result(distinct: true)
			.includes(:book, :user, :course_teacherships)
			.page(params[:page]).per(15)
	
		@recent = BookTradeInfo.recents				
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
		#@res=self_books
		@res=[]
		
    #for i in 1..3
		google_books = GoogleBooks.search(params[:title],{:count=>20})
		#total=google_books.total_itmes
		res=google_books.map{|book|{
			:title=>book.title,
			:authors=>book.authors,
			:isbn=>book.isbn,
			:description=>book.description,
			:image_link=>book.image_link,
			:preview_link=>book.preview_link
		}}
			#break if google_books.count==0
			
    @res+=res
		#end
    
		respond_to do |format|
			format.json{render json: @res}
		end
  end
  
  def show
    @sale_book=BookTradeInfo.find(params[:id])    
		if @sale_book.status != 1
      @sale_book.incViewTimes! 
    end
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
		if params[:book].present?
			@book=@book_trade_info.book
			@book.update(
				book_params
			)
		end
		@book_trade_info.update(
			book_trade_info_params
		)
    
    # for update teachers 
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
			redirect_to book_path(@book_trade_info)
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
