class CourseMapSemIdToYear < ActiveRecord::Migration
  def up
	
		add_column :course_maps, :year, :integer, :after=>:desc
		
		CourseMap.includes(:semester).all.each do |cm|
			cm.year = cm.semester.year
			cm.save!
		end
		remove_column :course_maps, :semester_id
		
  end
	
	def down
		remove_column :course_maps, :year
	end
end
