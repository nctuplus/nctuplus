class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
	  t.string :name
	  t.string :email 
	  t.integer :grade_id
	  t.integer :activated
	  t.string :activate_token
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at

      t.timestamps
    end
  end
end
