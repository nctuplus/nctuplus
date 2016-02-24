class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
			t.string :event_type
			t.string :title, :null=>false
			t.string :organization
			t.string :location, :null=>false
			t.string :lat_long
			t.string :url, :limit=>2083
			t.text :content, :limit => 4294967295, :null=>false
			t.datetime :begin_time, :null=>false
			t.datetime :end_time, :null=>false
			t.integer :user_id, :null=>false
			t.integer :view_times, :null=>false, :default=>0
			t.boolean :banner, :default=>false
			t.attachment :cover
      t.timestamps
    end
		add_index :events, :user_id
  end
end
