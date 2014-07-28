class AddColumnDegreeToGrade < ActiveRecord::Migration
  def change
		add_column :grades, :degree, :integer, after: :name
  end
end
