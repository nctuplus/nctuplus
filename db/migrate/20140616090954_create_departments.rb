class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
	  t.string :ch_name
	  t.string :eng_name
	  t.string :real_id
	  t.string :degree
	  t.integer :college_id
      t.timestamps
    end
	add_index :departments, :real_id
	add_index :departments, :degree
	add_index :departments, :college_id
  end
end
