class RemoveColumnPass < ActiveRecord::Migration
  def change
  	remove_column :course_fields, :pass
  end
end
