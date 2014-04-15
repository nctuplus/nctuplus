class CreateFileInfo < ActiveRecord::Migration
  def change
    create_table :file_infos, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :owner_id
	  t.integer :course_id
	  t.integer :size
	  t.string :name
      t.timestamps
    end
  end
end
