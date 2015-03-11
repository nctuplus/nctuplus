class CourseTeachership < ActiveRecord::Base
	#alias_method_chain :belongs_to, :polymorphism
  belongs_to :course
	belongs_to :teachers#, polymorphic: true

	#has_many :teachers
  has_many :course_details, :dependent=> :destroy
	#has_many :course_teacher_ratings, :dependent=> :destroy
	has_many :new_course_teacher_ratings, :dependent=> :destroy
	validates_associated :new_course_teacher_ratings
	

  has_one :course_content_head
  has_many :course_content_lists
	has_many :comments
	has_many :file_infos
	validates_associated :file_infos
	has_many :discusses
	validates_associated :discusses

	class ScoreObj
		attr_accessor :rate_count, :avg_score, :arr
		def initialize(obj)
			self.arr=obj
			score_arr=obj.map{|rate|rate.score}
			self.rate_count=score_arr.length
			self.avg_score=rate_count==0 ? 0 : score_arr.reduce(:+)/rate_count
		end
	end

	def cold_ratings
		return ScoreObj.new(self.new_course_teacher_ratings.where(:rating_type=>1).all)
	end
	def sweety_ratings
		return ScoreObj.new(self.new_course_teacher_ratings.where(:rating_type=>2).all)
	end
	def hardness_ratings
		return ScoreObj.new(self.new_course_teacher_ratings.where(:rating_type=>3).all)
	end
	
	def _teachers
		return Teacher.where(:id=>JSON.parse(self.teacher_id))
	end
	
	#def teachers
	#	Teacher.where(:id=>JSON.parse(self.teacher_id))
	#end
	
	def teacher_name
		return "N/A" if self._teachers.empty?
		
		res=self._teachers.first.name+","
		self._teachers.each_with_index do |t,index|
			next if index==0
			res<<t.name<<','
		end
		return res[0..-2]
	end
  
	
	
	
  #belongs_to :teacher
	
end
