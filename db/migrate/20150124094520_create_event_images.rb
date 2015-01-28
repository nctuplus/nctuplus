class CreateEventImages < ActiveRecord::Migration
  def change
    create_table :event_images do |t|
			t.integer :event_id
      t.timestamps
    end
		add_index :event_images, :event_id
		add_attachment :event_images, :img
  end
end
