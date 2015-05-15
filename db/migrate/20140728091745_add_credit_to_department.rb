class AddCreditToDepartment < ActiveRecord::Migration
  def change
		add_column :departments, :credit, :integer, after: :dept_type
  end
end
