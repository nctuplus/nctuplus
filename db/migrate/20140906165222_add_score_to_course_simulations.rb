class AddScoreToCourseSimulations < ActiveRecord::Migration
  def change
		add_column :course_simulations, :score, :string, after:course_detail_id
  end
end
