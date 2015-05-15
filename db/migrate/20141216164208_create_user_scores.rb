class CreateUserScores < ActiveRecord::Migration
  def change
    create_table :user_scores do |t|
			t.integer :user_id, :null=>false
			#t.integer :target_id, :null=>false
			t.integer :course_field_id, :default=>0
			t.boolean :is_agreed
			t.text :score, :limit=>10
			t.references :courseorcd, :polymorphic => true
      t.timestamps
    end
		add_index :user_scores, :user_id
		add_index :user_scores, :target_id
		add_index :user_scores, :course_field_id
  end
end
