class ChangeUserGradeToSemester < ActiveRecord::Migration
  def change
		rename_column :users, :grade_id, :semester_id
  end
end
