class Semester < ActiveRecord::Base
  has_many :semester_courseships, :dependent => :destroy
  has_many :courses, :through => :semester_courseships
	has_many :course_details
	scope :current,->{find 13}
	def self.create_new	#when import new course needed
		name=['上','下','暑']
		new_sem=Semester.new
		last_sem=Semester.last
		if last_sem.half==3
			new_sem.half=1
			new_sem.year=last_sem.year+1
		else
			new_sem.half=last_sem.half+1
			new_sem.year=last_sem.year
		end
		new_sem.name=new_sem.year.to_s+name[new_sem.half-1]
		return new_sem
		
	end
	
end
