class RemoveColumnUserAuth2 < ActiveRecord::Migration
  def change
    remove_column :users, :activate_token
  end
end
