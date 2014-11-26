class RemoveCfgIdFromCf < ActiveRecord::Migration
  def change
		remove_column :course_fields, :course_field_group_id
  end
end
