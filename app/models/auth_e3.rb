class AuthE3 < ActiveRecord::Base
  belongs_to :user
  
  def to_json
    {
      :student_id=> self.student_id
    }
  end
  
  def self.from_omniauth(student_id, password)
    data = E3Service.login(student_id, password)
    if data[:auth]
      auth_e3 = where(:student_id=>student_id).first_or_initialize.tap do |e|
        e.student_id=student_id       
        unless e.user_id
          user = User.create_from_auth({
            :provider=>"e3",
            :name=>student_id,
            :password=>Devise.friendly_token[0,20],
            :email=>"#{Devise.friendly_token[0,8]}@please.change.me"
          })
          e.user_id = user.id
        end 
        e.save!
      end
      return auth_e3.user     
    else
      return nil
    end
  end
  
end
