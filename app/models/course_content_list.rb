class CourseContentList < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :user
	has_many :content_list_ranks, :dependent => :destroy
	
	has_many :likes,->{where rank:1}, :class_name=>"ContentListRank", counter_cache: true
	has_many :unlikes,->{where rank:2}, :class_name=>"ContentListRank", counter_cache: true
	
	def to_content_list(ismy, current_user)
		if current_user
			voted = (self.content_list_ranks.where('user_id= ?',current_user.id).empty?) ? "0" : "1"
		else
			voted = "0" 
		end
		{
			:id=> self.id,
			:content_type=> content_type_info(self.content_type),
			:content=> self.content,
			:user_name=> self.user.name,
			:time=> self.updated_at.strftime('%Y/%m/%d %H:%M'),
			:rank_info=> {
						:likes=>self.likes.count.to_s , 
						:unlikes=>self.unlikes.count.to_s ,
						:voted=>  voted
						 },
			:is_my=> ismy
		}
	end
private
		
	def content_type_info(type)
		str = ''
		case type
			when 1 #考試
				str = "[考試]"
			when 2 #作業
				str = "[作業]"
			when 3 #上課
				str= "[上課]"
			when 4 #其他
				str = "[其他]"
		end	
		return {:id=> type, :name=> str}
	end	
	
end
