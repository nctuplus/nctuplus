class AddIsAnonymousToDiscuss < ActiveRecord::Migration
  def change
		add_column :discusses, :is_anonymous, :boolean, :default=>false, :after=> :content
		#add_column :sub_discusses, :is_anonymous, :boolean, :default=>false, :after=> :content
  end
end
