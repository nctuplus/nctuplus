class BookTradeInfo < ActiveRecord::Base
  belongs_to :user
	belongs_to :book
	has_many :course_teacherships, :through=>:book
  accepts_nested_attributes_for :book, :reject_if => :all_blank
	validates_numericality_of :price, :only_integer => true
	validates_length_of :desc, :maximum => 64
	validates_format_of :image_url, :with =>  /(^$)|(^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
end
