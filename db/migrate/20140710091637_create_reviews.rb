class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
			t.integer :bbs_id
			t.string :author 
			t.string :title
			t.text :content, :limit => 4294967295
      t.datetime :date
			t.integer :course_id
    end
		add_index :reviews, :course_id
  end
end
