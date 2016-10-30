class CreateAuthNctus < ActiveRecord::Migration
  def change
    create_table :auth_nctus do |t|
      t.integer :user_id
      t.string :student_id
      t.string :email
      t.string :oauth_token
      t.datetime :oauth_expires_at

      t.timestamps
    end
  end
end
