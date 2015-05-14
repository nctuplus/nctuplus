class AddColumnsToCourses < ActiveRecord::Migration
  def change
		add_column :courses, :credit, :integer, after: :eng_name
		remove_column :courses, :grade_id
  end
end
