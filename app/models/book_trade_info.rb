class BookTradeInfo < ActiveRecord::Base
	include ActionView::Helpers

  belongs_to :user
	belongs_to :book
	delegate :image_link, :to=>:book, :prefix=>true
	
	has_many :book_trade_info_ctsships
	has_many :course_teacherships, :through=>:book_trade_info_ctsships
  has_many :courses, :through=>:course_teacherships
	has_many :colleges, :through=> :course_teacherships
	
	has_many :course_details, :through=>:course_teacherships
	has_many :departments, :through=>:course_details
	
	validates_numericality_of :price, :only_integer => true
	#validates_length_of :desc, :maximum => 64
	
	has_attached_file :cover,
		:url=>"/file_upload/book_covers/:id_partition/:filename",
		:default_url => "/images/:style/missing.png",
		:path => ":rails_root/public/file_upload/book_covers/:id_partition/:filename"#,
		#:styles => { default: "300x300#" }
  validates_attachment :cover,
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 2.megabytes }

	def self.recents
		recent_sold = where(:status=>1).order("updated_at DESC")
				.includes(:book).limit(5)
				.map{|b| {:status=>"sold", :name=>b.book_name, :time=>b.updated_at} }
		recent_books = order("created_at DESC").includes(:book).limit(5)	
				.map{|b| {:id=>b.id, :status=>"new", :name=>b.book_name, :time=>b.created_at} }
		return (recent_sold+recent_books).sort_by{|e| e[:time]}.reverse 
	end
	

	
	def incViewTimes!
		update_attributes(:view_times=>self.view_times+1)
	end
  
# no use?  
=begin	
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
=end

	def cover_image(zoom=1)
		if self.cover_file_name
			
			url=self.cover.url
		else 
			if self.book.image_link.blank?
				url=ActionController::Base.helpers.asset_path("book_default.png")
			else
				url=self.book.image_link_with_zoom(zoom)
			end
		end
		return image_tag(url,style: zoom==1 ? "height:170px;min-height:150px;" : "max-width:200px;",alt:"尚無圖片!")
	end
private
	ransacker :cts_exists do |parent|	#for 無分類 
		# SQL syntax for PostgreSQL -- others may differ
		# This returns boolean true or false
		Arel.sql("(select exists (select 1 from book_trade_info_ctsships where book_trade_info_ctsships.book_trade_info_id = book_trade_infos.id))")
	end
end