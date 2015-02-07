class CreateNewDepartments < ActiveRecord::Migration
  def change
    create_table :new_departments do |t|
			t.integer :degree
			t.string :dept_type
			t.string :dep_id
			t.string :ch_name
			t.string :eng_name
			t.string :use_type
      t.timestamps
    end
  end
end
