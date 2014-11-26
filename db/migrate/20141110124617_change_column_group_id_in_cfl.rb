class ChangeColumnGroupIdInCfl < ActiveRecord::Migration
  def change
  	rename_column :course_field_lists, :group_id, :course_group_id
  end
end
