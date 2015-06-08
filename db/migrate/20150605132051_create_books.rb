class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
			t.string :title, :null=>false, :default=>""
			t.string :isbn
			t.string :authors
			t.text :description
			t.text :image_link
			t.text :preview_link
			t.integer :user_id, :null=>false, :default=>0
      t.timestamps
    end
		add_index :books, :user_id
		create_table :book_ctsships do |t|
			t.integer :book_id
			t.integer :course_teachership_id
			t.timestamps
		end
		add_index :book_ctsships, :book_id
		add_index :book_ctsships, :course_teachership_id
  end
end
