class Department < ActiveRecord::Base
  has_many :courses
	has_many :users
	belongs_to :college
	scope :searchable,->{where has_courses: true}
	scope :majorable,->{where majorable: true}
	scope :undergraduate,->{where degree: 3}
	scope :graduate,->{where degree: 2}
	
	def is_graduate?
		return self.degree==2
	end
	
	def is_undergraduate?
		return self.degree==3
	end
	
	def pass_score
		return self.degree==2 ? 70 : 60
	end
	def self.create_from_e3(data)
		Department.find_or_create_by(:dep_id=>data["dep_id"],:degree=>data["degree"].to_i ) do |dept|
			dept.data_type=data["dataype"]
			dept.ch_name=data["dep_cname"]
			dept.eng_name=data["dep_ename"]
		end
	end
	def self.get_by_degree_and_depid(degree,dep_id)
		return 0 if dep_id==""
		return Department.where(:degree=>degree, :dep_id=>dep_id).take.try(:id)||0
		#return dept.nil? ? 0 : dept.id 
	end
end
