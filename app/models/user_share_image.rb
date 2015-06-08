class UserShareImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :semester
  has_attached_file :image
  
  
end
