class CourseTeachership < ActiveRecord::Base
  belongs_to :course
  has_many :course_details, :dependent=> :destroy
	has_many :course_teacher_ratings, :dependent=> :destroy
	has_many :discusses

  has_one :course_content_head
  has_many :course_content_lists

	has_many :file_infos
  #has_one :course_teacher_page_content

	def _teachers
		return Teacher.where(:id=>JSON.parse(self.teacher_id))
	end
	
	def teacher_name
		res=self._teachers.first.name+","
		self._teachers.each_with_index do |t,index|
			next if index==0
			res<<t.name<<','
		end
		return res[0..-2]
	end
  
  #belongs_to :teacher
	
end
