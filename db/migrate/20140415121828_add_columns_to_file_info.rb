class AddColumnsToFileInfo < ActiveRecord::Migration
  def change
   add_column :file_infos, :types, :string
   add_column :file_infos, :description, :string
   #add_index :file_infos, :owner_id
  end
end
