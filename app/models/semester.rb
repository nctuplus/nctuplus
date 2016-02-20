class Semester < ActiveRecord::Base
	#Use Constant for domain data 不會變的資料可以用常數在Rails啟動時就放到記憶體。
	CURRENT = self.find(GlobalVariable.settings[:current_semester_id])  #self.find(17)	
	LAST = self.last	#如果有新的課程可以匯入了,(如:103下的6月已開104上的課),需要開一個新的學期去存 此時LAST!=CURRENT
	YEARS = self.uniq.pluck(:year)
	
  has_many :semester_courseships, :dependent => :destroy
  has_many :courses, :through => :semester_courseships
	has_many :course_details
	
	
	
	def self.create_new	#when import new course needed
		name=['上','下','暑']
		new_sem=Semester.new
		last_sem=Semester::LAST
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
