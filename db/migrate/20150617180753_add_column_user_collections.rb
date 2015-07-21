class AddColumnUserCollections < ActiveRecord::Migration
  def change
    add_column :user_collections, :name, :string, :after=>"semester_id", :default=>"" 
  end
end
