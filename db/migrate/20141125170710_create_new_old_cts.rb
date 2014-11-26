class CreateNewOldCts < ActiveRecord::Migration
  def change
    create_table :new_old_cts do |t|
			t.integer :old_ct_id
			t.integer :new_ct_id
      t.timestamps
    end
  end
end
