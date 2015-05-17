class CreateAuthFacebooks < ActiveRecord::Migration
  def up
    create_table(:auth_facebooks, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.timestamps
    end
    
    User.where("uid IS NOT NULL").each do |u|
      AuthFacebook.create(
        :user_id =>u.id,
        :uid=>u.uid,
        :oauth_token=>u.oauth_token,
        :oauth_expires_at=>u.oauth_expires_at 
      )
    
    end
    
  end
  
  def down
    drop_table :auth_facebooks
  end
end
