class BookTradeInfo < ActiveRecord::Base
  belongs_to :user
	
	validates_numericality_of :price, :only_integer => true
	validates_length_of :desc, :maximum => 64
	validates_format_of :url, :with =>  /(^$)|(^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
end
