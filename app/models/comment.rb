class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_teachership  
	
	def to_hash 
		{
			:content_type=> {:id=>self.content_type, :name=>type_name(self.content_type)},
			:content=> self.content,
			:time=> self.updated_at.strftime('%Y/%m/%d %H:%M'),
			:user_name=> self.user.name
		}
	end

private	
	def type_name(id)
		case id
			when 1
				"推"
			when 2
				"→"
			else
				"噓"
		end
	end
	
end
