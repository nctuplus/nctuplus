class AddColumnCfGroupInfo < ActiveRecord::Migration
  def change
  	add_column :course_field_lists, :group_id, :integer, :default=> 0
  end
end
