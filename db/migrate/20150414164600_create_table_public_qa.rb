class CreateTablePublicQa < ActiveRecord::Migration
  def change
    create_table :course_map_public_comments do |t|
    	t.integer :user_id
    	t.string  :comments
    	t.integer :course_map_public_comment_id
    	
    	t.timestamps
    end
  end
end
