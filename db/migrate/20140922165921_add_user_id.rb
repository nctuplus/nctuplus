class AddUserId < ActiveRecord::Migration
  def change
  	add_column :course_maps, :user_id, :integer
  	add_column :course_field_groups, :user_id, :integer
  	add_column :course_fields, :user_id, :integer
  end
end
