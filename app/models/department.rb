class Department < ActiveRecord::Base
  has_many :courses
	has_many :users
	scope :searchable,->{where use_type:['dept','common']}
	scope :can_majored,->{where "(use_type = 'dept' AND dep_id != '17' AND dep_id !='44')  OR use_type = 'for_user' "}
	scope :undergraduate,->{where degree:3}
	scope :graduate,->{where degree:2}

	def majorable?
		return self.nil? ? false :
		  (self.use_type=="dept"&& self.dep_id != '17' && self.dep_id !='44') || self.use_type == 'for_user'
	end
end
