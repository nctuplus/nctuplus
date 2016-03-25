class Event < ActiveRecord::Base
	
	belongs_to :user
	has_many :attendances
	has_many :attendees, :through=> :attendances, :class_name=>"User"
	has_many :event_follows
	has_many :followers, :through=> :event_follows, :class_name=>"User"
	has_attached_file :cover,
		:url=>"/file_upload/event_covers/:id_partition/:filename",
		:default_url => "events/banner_logo_transparent.png",
		:path => ":rails_root/public/file_upload/event_covers/:id_partition/:filename"
	validates_attachment :cover, 
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 2.megabytes }
		
	def self.typeSel
		return ["校友週","講座","表演","擺攤","比賽","其他"]
		#return ["梅竹","講座","表演","擺攤","比賽","其他"]
	end
	
	def incViewTimes!
		#self.record_timestamps = false
			update_attributes(:view_times=>self.view_times+1)
	  #self.record_timestamps = true
	end
	
	def to_json_obj
		{
			:id=>self.id,
			:title=>self.title,
			:start=>self.begin_time.strftime("%Y-%m-%dT%H:%M:00"),
			:end=>self.end_time.strftime("%Y-%m-%dT%H:%M:00"),
			:className=>self.event_type
		}
	end
	
	def is_past?
		return self.end_time < Time.now
	end

	def is_future?
		return self.begin_time.to_date > Date.today.to_date
	end	
	
	def get_time
		if self.is_past?
			return self.end_time.strftime("%m/%d")
		elsif self.is_future?
			return self.begin_time.strftime("%m/%d")
		else
			if self.begin_time > Time.now
				return "今 " + self.begin_time.strftime("%H:%M")
			else
				return "進行中"
			end
		end
	end
	
	def get_time_css
		if self.is_past?
			return "event-date__theme--past"
		elsif self.is_future?
			return "event-date__theme--future"
		else
			return "event-date__theme--today"
		end
	end	
	
	def get_banner_url
		return self.cover.url
	end
	
	def get_block_theme
		if self.is_past?
			return "event-block__theme--past"
		elsif self.is_future?
			return "event-block__theme--future"
		else
			return "event-block__theme--today"
		end
	end
	
end