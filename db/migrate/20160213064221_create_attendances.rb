class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
			t.integer :user_id
			t.integer :event_id
      t.timestamps
    end
		add_index :attendances, :user_id
		add_index :attendances, :event_id
  end
end
