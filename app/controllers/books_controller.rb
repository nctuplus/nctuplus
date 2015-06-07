class BooksController < ApplicationController
  
  def show
    redirect_to "/main/book_test"
  end
  
  def new
    @book = BookTradeInfo.new
    @list = BookTradeInfo.all
  end
  
  def create
    params[:book][:user_id]=current_user.id
    @book = BookTradeInfo.new(book_params)
    @book.save
    redirect_to :action => "new"
  end
  
  private
    def book_params
      params.require(:book_trade_info).permit(:user_id, :book_name, :image_url, :price, :desc)
    end
  
  
  
end
