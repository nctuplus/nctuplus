class UserEmailInitailize < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.email = "#{Devise.friendly_token[0,8]}@please.change.me"
      user.save
    end
  end
end
