class BookTradeInfoCtsship < ActiveRecord::Base
	belongs_to :book_trade_info
	belongs_to :course_teachership
end