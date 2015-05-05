class AddVirtualToCourses < ActiveRecord::Migration
  def change
		add_column :courses, :is_virtual, :boolean, :null=>false, :default=>false, :after=>"department_id"
  end
end
