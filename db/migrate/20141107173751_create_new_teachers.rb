class CreateNewTeachers < ActiveRecord::Migration
  def change
    create_table :new_teachers do |t|
			t.string :real_id
			t.string :name
			t.boolean :is_deleted
      t.timestamps
    end
  end
end
