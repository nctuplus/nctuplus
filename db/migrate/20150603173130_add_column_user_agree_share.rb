class AddColumnUserAgreeShare < ActiveRecord::Migration
  def change
    add_column :users, :agree_share, :boolean, :default=>false, :after=>:agree
  end
end
