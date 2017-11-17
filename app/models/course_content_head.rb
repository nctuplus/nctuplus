class CourseContentHead < ApplicationRecord
	belongs_to :course_teachership
	
	def to_hash
		{
			:exam_record=>self.exam_record,
			:homework_record=>self.homework_record,
			:rollcall_info=>rollcall_info(self.course_rollcall)
		}
	end

private 

	def rollcall_info(id)
		case id
			when 1 #
				{:id=>id, :name=>"每堂必點", :color=>"danger"}
			when 2 #
				{:id=>id, :name=>"經常抽點", :color=>"warning"}
			when 3 #
				{:id=>id, :name=>"偶爾抽點", :color=>"primary"}
			when 4 #
				{:id=>id, :name=>"不點名", :color=>"success"}
		end	
	end		
	
end
