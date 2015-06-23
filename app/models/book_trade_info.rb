class BookTradeInfo < ActiveRecord::Base
	include ActionView::Helpers

  belongs_to :user
	belongs_to :book
	delegate :image_link, :to=>:book, :prefix=>true
	
	has_many :book_trade_info_ctsships
	has_many :course_teacherships, :through=>:book_trade_info_ctsships
  has_many :courses, :through=>:course_teacherships
	
	validates_numericality_of :price, :only_integer => true
	validates_length_of :desc, :maximum => 64
	
	has_attached_file :cover,
		:url=>"/file_upload/book_covers/:id_partition/:filename",
		:default_url => "/images/:style/missing.png",
		:path => ":rails_root/public/file_upload/book_covers/:id_partition/:filename"
  validates_attachment :cover, 
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 2.megabytes }
		
	def self.search_by_q(q)
		search({
			:book_name_or_book_authors_or_course_ch_name_cont=>q,
		})
	end
	
	def incViewTimes!
		update_attributes(:view_times=>self.view_times+1)
	end
	
	def user_avatar
		if self.contact_way==0
			url=ActionController::Base.helpers.asset_path("mail.png")
		elsif self.contact_way==1
			url="http://graph.facebook.com/#{self.user.uid}/picture"
		end
		return image_tag(url,size:"25x25", style:"border-radius:3px;")
	end
	def user_name_with_tip
		if self.contact_way==0
			return "<span data-toggle='tooltip' title='#{self.user.email}'>#{self.user.name}</span>".html_safe
		elsif self.contact_way==1
			return link_to(self.user.name,"http://www.facebook.com/#{self.user.uid}",target:"_blank")
		end
	end

	def cover_image(zoom=1)
		if self.cover_file_name 
			url=self.cover.url
		else 
			#return "尚無圖片!" if self.book.image_link.blank?
			url=self.book.image_link_with_zoom(zoom)
		end
		return image_tag(url,style: zoom==1 ? "height:170px;min-height:150px;" : "max-width:200px;",alt:"尚無圖片!")
	end
end
