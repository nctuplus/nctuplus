class CreateAuthE3s < ActiveRecord::Migration
  def up
    create_table(:auth_e3s, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :user_id
      t.string :student_id
      t.timestamps
    end
    
    User.where("users.student_id IS NOT NULL").each do |u|
      AuthE3.create(:user_id=>u.id, :student_id=>u.student_id)     
    end    
  end
  
  def down
    drop_table :auth_e3s
  end
  
end
