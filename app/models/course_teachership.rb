class CourseTeachership < ActiveRecord::Base
	#alias_method_chain :belongs_to, :polymorphism
  belongs_to :course
	delegate :ch_name, :to=>:course, :prefix=>true
	
	belongs_to :teacher
	
  has_many :course_details, :dependent=> :destroy
	has_many :semesters, :through=> :course_details
	has_many :departments, :through=> :course_details
	has_many :colleges, :through=> :departments
	
	has_many :course_teacher_ratings, :dependent=> :destroy
	validates_associated :course_teacher_ratings
	

  has_one :course_content_head
  has_many :course_content_lists
	has_many :comments
	has_many :past_exams
	validates_associated :past_exams
	has_many :discusses
	validates_associated :discusses


	
	class ScoreObj
		attr_accessor :rate_count, :avg_score, :arr
		def initialize(obj)
			self.arr=obj
			score_arr=obj.map{|rate|rate[:score]}
			self.rate_count=score_arr.length
			self.avg_score=rate_count==0 ? 0.to_s : (score_arr.reduce(:+)/rate_count.to_f).to_s
		end
	end

	def cold_ratings
		return ScoreObj.new(self.course_teacher_ratings.where(:rating_type=>1).map{|ctr|ctr.to_json_obj})
	end
	def sweety_ratings
		return ScoreObj.new(self.course_teacher_ratings.where(:rating_type=>2).map{|ctr|ctr.to_json_obj})
	end
	def hardness_ratings
		return ScoreObj.new(self.course_teacher_ratings.where(:rating_type=>3).map{|ctr|ctr.to_json_obj})
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
