class UserCollection < ApplicationRecord
  belongs_to :user, :foreign_key=> :target_id
  belongs_to :semester
  

end
