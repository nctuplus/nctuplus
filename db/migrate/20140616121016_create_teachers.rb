class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
	  t.string :name
	  t.integer :department_id
      t.timestamps
    end
  end
end
