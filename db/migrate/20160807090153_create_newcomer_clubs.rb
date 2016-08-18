class CreateNewcomerClubs < ActiveRecord::Migration
  def change
    create_table :newcomer_clubs do |t|
      t.string :category
      t.string :name
      t.string :pdf
      t.string :web
      t.string :fb
      t.string :img
      t.string :group
      t.string :color

      t.timestamps
    end
  end
end
