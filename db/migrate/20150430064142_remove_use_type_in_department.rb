class RemoveUseTypeInDepartment < ActiveRecord::Migration
  def change
		remove_column :departments, :use_type
  end
end
