class DropNewcomerClubs < ActiveRecord::Migration
  def change
    drop_table :newcomer_clubs
  end
end
