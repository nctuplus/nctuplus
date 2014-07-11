class AddViewableToDepartment < ActiveRecord::Migration
  def change
    add_column :departments, :viewable, :string
  end
end
