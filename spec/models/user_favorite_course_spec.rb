require 'rails_helper'

RSpec.describe UserFavoriteCourse, type: :model do
  before(:all) do
    ActiveRecord::Base.connection.execute("TRUNCATE users")
    ActiveRecord::Base.connection.execute("TRUNCATE course_details")
    #ActiveRecord::Base.connection.execute("TRUNCATE user_favorite_courses")
    ActiveRecord::Base.connection.execute("TRUNCATE auth_e3s")
    @user=create_e3_user
    @cd=CourseDetail.create(
      :course_teachership_id=>"123",
      :department_id=>"123",
      :view_times=>"0"
    )                                                                                                     
    puts "user's id is :" + @user.id.to_s
    puts "course_detail's id is:" + @cd.id.to_s
  end 

  after(:all) do
    User.delete(@user)
    CourseDetail.delete(@cd)
  end

  it "should create a UserFavoriteCourse when user add a favorite course" do
    @user.course_details << @cd
    u_cd=UserFavoriteCourse.find_by(course_detail_id: @cd.id)
    expect(@user.user_favorite_courses).to include(u_cd) 
  end

  it "should delete a UserFavoriteCourse when user delete a favorite course" do
    @user.course_details.delete(@cd)
    u_cd=UserFavoriteCourse.find_by(course_detail_id: @cd.id)
    expect(@user.user_favorite_courses).not_to include(u_cd) 
  end

  def create_e3_user
    puts "Creating E3 user"
    user=User.create(
      :name=>"E3 user",
      :email=>"E3@ggmail.com",
      :encrypted_password=>"12345678",
      :sign_in_count=>0
    )                                                                                                     
    user.create_auth_e3(:student_id=>"0012345")
    return user
  end     
end
