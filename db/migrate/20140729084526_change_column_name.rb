class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :raider_content_lists, :type, :content_type
  end
end
