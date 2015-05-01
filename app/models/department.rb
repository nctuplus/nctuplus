class Department < ActiveRecord::Base
  has_many :courses
	has_many :users
	belongs_to :college
	scope :searchable,->{where has_courses: true}
	scope :majorable,->{where majorable: true}
	scope :undergraduate,->{where degree: 3}
	scope :graduate,->{where degree: 2}

end
