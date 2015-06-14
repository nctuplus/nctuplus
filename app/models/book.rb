class Book < ActiveRecord::Base
  has_many :book_trade_infos
	has_many :book_ctsships
	has_many :course_teacherships, :through=> :book_ctsships
	belongs_to :user
	def image_link_with_zoom(zoom=1)
		self.image_link.sub!("zoom=1","zoom=#{zoom}")
	end
end
