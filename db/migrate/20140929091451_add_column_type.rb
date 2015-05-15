class AddColumnType < ActiveRecord::Migration
  def change
  	add_column :course_group_lists, :lead, :integer, :default=>0
  	add_column :course_groups, :gtype, :integer, :default=>0
  end
end
