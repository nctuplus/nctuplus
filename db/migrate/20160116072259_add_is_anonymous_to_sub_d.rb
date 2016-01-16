class AddIsAnonymousToSubD < ActiveRecord::Migration
  def change
		add_column :sub_discusses, :is_anonymous, :boolean, :default=>false, :after=> :content
		remove_column :sub_discusses, :likes
		remove_column :sub_discusses, :dislikes
		remove_column :discusses, :likes
		remove_column :discusses, :dislikes
  end
end
