class ChangeCourseMapsColumn < ActiveRecord::Migration
  def change
		change_column :course_field_groups, :credit_need, :integer
		change_column :course_fields, :credit_need, :integer
		change_column :course_fields, :user_id, :integer, after: :course_field_group_id
		add_column :course_fields, :color, :text, after: :credit_need
  end
end
