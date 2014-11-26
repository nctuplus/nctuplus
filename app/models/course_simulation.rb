class CourseSimulation < ActiveRecord::Base
	belongs_to :user
	belongs_to :course_detail
	has_one :course, :through=>:course_detail
	has_one :teacher, :through=>:course_detail
	has_one :course_teachership, :through=>:course_detail
	belongs_to :semester
	belongs_to :course_field
	def self.filter_semester(sem_id)
		self.select{|cs| cs.semester_id==sem_id}
	end
	
	def to_simulated
		{
			"name"=>CourseDetail.find(read_attribute(:course_detail_id)).course_teachership.course.ch_name,
			"time"=>CourseDetail.find(read_attribute(:course_detail_id)).time_and_room.partition("-")[0]
		}
	end
	
end
