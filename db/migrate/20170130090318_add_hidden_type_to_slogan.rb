class AddHiddenTypeToSlogan < ActiveRecord::Migration
  def change
    add_column :slogans, :hidden_type, :boolean, :null => false, :default => false
  end
end
