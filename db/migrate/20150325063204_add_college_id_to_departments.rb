class AddCollegeIdToDepartments < ActiveRecord::Migration
  def change
		add_column :departments, :college_id, :integer, :default=> 0, :after=> :dep_id
		add_index :departments, :college_id
	end
end
