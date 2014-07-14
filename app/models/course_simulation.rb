class CourseSimulation < ActiveRecord::Base
	belongs_to :user
	belongs_to :course_detail
	
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
