class AddContactWayToBookTradeInfos < ActiveRecord::Migration
  def change
		add_column :book_trade_infos, :contact_way, :integer, :after=>:user_id, :default=>0, :null=>false
		add_index :book_trade_infos, :user_id
		add_index :book_trade_infos, :book_id
  end
end
