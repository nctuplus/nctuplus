class RenameColumnListRnak < ActiveRecord::Migration
  def change
  	rename_column :content_list_ranks, :raider_content_list_id, :course_content_list_id
  end
end
