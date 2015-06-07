class BooksController < ApplicationController
  
	#before_filter :checkLogin
	#before_filter :checkE3Login
	
  def google_book
		@res = GoogleBooks.search(params[:title],{:count => 5}) 
		render :json => @res
  end
  
  def show
    redirect_to "/main/book_test"
  end
  
  def new
    @book = BookTradeInfo.new
    @list = BookTradeInfo.all
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
