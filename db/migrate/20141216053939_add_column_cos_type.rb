class AddColumnCosType < ActiveRecord::Migration
  def change
	add_column :temp_course_simulations, :cos_type, :string, :default=>""
	add_column :course_simulations, :cos_type, :string, :default=>""
  end
end
