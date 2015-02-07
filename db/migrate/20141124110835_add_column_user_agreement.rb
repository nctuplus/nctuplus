class AddColumnUserAgreement < ActiveRecord::Migration
  def change
	add_column :users, :agree, :boolean, :default=>false
  end
end
