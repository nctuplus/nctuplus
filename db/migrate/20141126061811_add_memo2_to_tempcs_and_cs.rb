class AddMemo2ToTempcsAndCs < ActiveRecord::Migration
  def change
		add_column :temp_course_simulations, :memo2, :string, after: :memo
		add_column :course_simulations, :memo2, :string, after: :memo
  end
end
