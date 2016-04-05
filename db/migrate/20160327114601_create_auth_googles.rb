class CreateAuthGoogles < ActiveRecord::Migration
  def change
    create_table :auth_googles do |t|
      t.integer :user_id
    
    # default profile
      t.string :uid
      t.string :email
      t.string :name
      t.string :image_url
      
    # extra  
      t.string :gender
      t.date :birthday
      t.string :location
      
    # oauth token info  
      t.string :oauth_token
      t.datetime :oauth_expires_at
      
      t.timestamps
    end
  end
end
