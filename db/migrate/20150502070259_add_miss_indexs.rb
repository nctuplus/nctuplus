class AddMissIndexs < ActiveRecord::Migration
  def change
		add_index :cf_field_need, :course_field_id
		add_index :course_details , :department_id
		add_index :course_field_lists , :course_field_id
		add_index :course_field_lists , :course_id
		add_index :course_field_lists , :course_group_id
		add_index :course_field_lists , :user_id
		add_index :course_fields , :user_id
		add_index :course_group_lists , :course_group_id
		add_index :course_group_lists , :course_id
		add_index :course_group_lists , :user_id
		add_index :course_groups , :user_id
		add_index :course_groups , :course_map_id
		add_index :course_map_public_comments , :user_id
		add_index :course_map_public_comments , :course_map_id
		add_index :course_map_public_sub_comments , :user_id
		rename_column :course_map_public_sub_comments, :course_map_public_comment_id, :comment_id
		add_index :course_map_public_sub_comments , :comment_id
		add_index :course_map_public_sub_comments , :course_map_id
		add_index :course_maps , :department_id
		add_index :course_maps , :user_id
		add_index :course_teacherships , :teacher_id
		add_index :courses , :department_id
		add_index :past_exams , :user_id
		add_index :past_exams , :course_teachership_id
		add_index :past_exams , :semester_id
		add_index :sub_discusses , :user_id
		add_index :temp_course_simulations , :semester_id
		add_index :temp_course_simulations , :course_detail_id
		add_index :temp_course_simulations , :course_field_id
  end
end
