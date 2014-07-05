class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
	  t.string :name
	  t.string :real_id 
      t.timestamps
    end
  end
end
