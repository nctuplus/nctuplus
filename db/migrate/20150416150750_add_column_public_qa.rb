class AddColumnPublicQa < ActiveRecord::Migration
  def change
  	add_column :course_map_public_comments, :course_map_id, :integer
  	add_column :course_map_public_comments, :checked, :integer, :default=>0
  end
end
