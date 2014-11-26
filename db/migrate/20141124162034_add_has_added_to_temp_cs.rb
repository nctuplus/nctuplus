class AddHasAddedToTempCs < ActiveRecord::Migration
  def change
		add_column :temp_course_simulations, :has_added, :boolean, after: :memo
  end
end
