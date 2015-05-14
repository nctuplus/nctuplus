class AddColumnImportFailCs < ActiveRecord::Migration
  def change
	add_column :course_simulations, :import_fail, :integer, :default=>0
  end
end
