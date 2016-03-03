class AddColumnUpdateUserToBulletin < ActiveRecord::Migration
  def change
  	 add_column :bulletins, :update_user, :string
  	 add_column :bulletins, :hidden_type, :boolean, :null => false, :default => false
  end
end
