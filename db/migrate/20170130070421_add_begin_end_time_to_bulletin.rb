class AddBeginEndTimeToBulletin < ActiveRecord::Migration
  def change
     add_column :bulletins, :begin_time, :datetime, :default => '1990-11-17'
     add_column :bulletins, :end_time, :datetime, :default => '4000-12-31'
  end
end
