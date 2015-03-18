class AddColumnUserStudentId < ActiveRecord::Migration
  def change
  	add_column :users, :student_id, :string
  end
end
