class RenameViewableToDepartment < ActiveRecord::Migration
  def change
		rename_column :departments, :viewable, :dept_type
		change_column :departments, :dept_type, :string, after: :college_id
  end
end
