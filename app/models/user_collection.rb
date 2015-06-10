class UserCollection < ActiveRecord::Base
  belongs_to :user, :foreign_key=> :target_id
  belongs_to :semester
  
end
