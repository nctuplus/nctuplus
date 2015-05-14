class CreateColleges < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
	  t.string :name
	  t.string :real_id
    t.timestamps
    end
  end
end
