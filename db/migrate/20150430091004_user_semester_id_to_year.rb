class UserSemesterIdToYear < ActiveRecord::Migration
   def up
	
		add_column :users, :year, :integer, :after=>:name, :default=>0, :nil=>false
		
		User.includes(:semester).all.each do |user|
			next if user.semester.nil?
			user.year = user.semester.year
			user.save!
		end
		remove_column :users, :semester_id
		
  end
	
	def down
		remove_column :course_maps, :year
	end
end
