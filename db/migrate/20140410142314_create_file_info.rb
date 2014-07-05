class CreateFileInfo < ActiveRecord::Migration
  def change
    create_table :file_infos, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :owner_id
	  t.integer :course_id
	  t.string :description
	  t.integer :teacher_id
	  t.integer :semester_id
	  #t.integer :size
	  #t.string :name
	  t.string   "upload_file_name"
      t.string   "upload_content_type"
      t.integer  "upload_file_size"
      t.datetime "upload_updated_at"
      t.timestamps
    end
  end
end
