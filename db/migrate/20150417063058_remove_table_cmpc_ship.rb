class RemoveTableCmpcShip < ActiveRecord::Migration
  def change
		drop_table  :course_map_public_comment_selfships
  end
end
