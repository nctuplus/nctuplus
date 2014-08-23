class Comment < ActiveRecord::Base
  #attr_accessible :content, :content_type  
  
  belongs_to :user
  belongs_to :course_teachership  
end
