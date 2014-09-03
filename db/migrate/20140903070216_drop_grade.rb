class DropGrade < ActiveRecord::Migration
  def change
		drop_table :grades
  end
end
