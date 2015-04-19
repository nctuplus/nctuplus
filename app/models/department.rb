class Department < ActiveRecord::Base
  has_many :courses
	has_many :users
	belongs_to :college
	scope :searchable,->{where has_courses: true}
	#scope :majorable,->{where has_courses: true}
	scope :undergraduate,->{where degree: 3}
	scope :graduate,->{where degree: 2}

=begin
	def majorable?
		return self.nil? ? false :
		  (self.use_type=="dept"&& self.dep_id != '17' && self.dep_id !='44') || self.use_type == 'for_user'
	end
=end
end
