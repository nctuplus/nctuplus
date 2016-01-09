class AddColumnNeedUpdateUserCmShip < ActiveRecord::Migration
  def change
		add_column :user_coursemapships, :need_update, :integer, :after=>:user_id, :default=>0
  end
end
