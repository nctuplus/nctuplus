class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
		  t.integer :target_id
			t.integer :user_id
			t.integer :score
			t.string :target_type
      t.timestamps
    end
  end
end
