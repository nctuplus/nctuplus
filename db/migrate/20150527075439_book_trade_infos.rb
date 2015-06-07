class BookTradeInfos < ActiveRecord::Migration
  def up
    create_table(:book_trade_infos, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :book_id, :default => 0, :null => false
      t.integer :user_id, :default => 0, :null => false
      t.string :book_name, :default => "", :null => false
      t.string :image_url, :default => "", :null => true
      t.integer :price, :default => 0, :null => false
      t.integer :status, :default => 0, :null => false
      t.integer :view_times, :default => 0, :null => false
      t.text :desc, :null => false
      
      t.timestamps
    end
  end
  
  def down
    drop_table :book_trade_infos
  end
end
