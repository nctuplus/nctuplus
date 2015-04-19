class AddGradeAndHalfToCfl < ActiveRecord::Migration
  def change
		change_column :course_field_lists, :course_group_id, :integer, :after=> :course_id
		change_column :course_field_lists, :record_type, :boolean, :after=> :course_group_id
		add_column :course_field_lists, :grade, :string, :default=>"*", :after=> :course_group_id
		add_column :course_field_lists, :half, :string, :default=>"*", :after=> :grade
  end
end
