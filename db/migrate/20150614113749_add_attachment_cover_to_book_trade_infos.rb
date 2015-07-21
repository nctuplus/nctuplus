class AddAttachmentCoverToBookTradeInfos < ActiveRecord::Migration
  def self.up
		add_column :book_trade_infos, :cover_file_name, :string, :after=>"desc"
		add_column :book_trade_infos, :cover_content_type, :string, :after=>"cover_file_name"
		add_column :book_trade_infos, :cover_file_size, :integer, :after=>"cover_content_type"
		add_column :book_trade_infos, :cover_updated_at, :datetime, :after=>"cover_file_size"
		remove_column :book_trade_infos, :image_url
  end

  def self.down
    drop_attached_file :book_trade_infos, :cover
  end
end
