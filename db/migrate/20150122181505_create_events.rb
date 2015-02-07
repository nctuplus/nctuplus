class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
			
			t.string :event_type
			t.integer :event_category_id
			t.string :title
			t.string :organization
			t.text :url, :limit=>2083
			t.text :content, :limit => 4294967295
			t.datetime :begin_time
			t.datetime :end_time
			t.integer :user_id
			t.integer :location_id
			t.integer :likes
			t.integer :view_times
      t.timestamps
    end
		add_index :events, :user_id
		add_index :events, :location_id
  end
end
