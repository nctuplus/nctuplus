class RemoveColumnCmpCommentCmpId < ActiveRecord::Migration
  def change
		remove_column :course_map_public_comments, :course_map_public_comment_id
  end
end
