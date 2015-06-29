class RemoveShareTable < ActiveRecord::Migration
  def change
		drop_table :user_share_images
  end
end
