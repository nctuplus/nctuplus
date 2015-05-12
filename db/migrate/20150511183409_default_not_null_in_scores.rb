class DefaultNotNullInScores < ActiveRecord::Migration
  def change
		change_column :normal_scores, :user_id, :integer, :null=>false
		change_column :normal_scores, :course_detail_id, :integer, :null=>false
		change_column :normal_scores, :course_field_id, :integer, :null=>false
		change_column :normal_scores, :cos_type, :string, :null=>false
		change_column :normal_scores, :score, :string, :null=>false
  end
end
