require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  before(:all) do
    ActiveRecord::Base.connection.execute("TRUNCATE users")        
    ActiveRecord::Base.connection.execute("TRUNCATE course_details")
    ActiveRecord::Base.connection.execute("TRUNCATE user_course_detailships")
    ActiveRecord::Base.connection.execute("TRUNCATE auth_e3s")
  end

  describe "#add_to_cart" do
    before(:all) do
      @current_user=create_e3_user
      @cd_to_add=CourseDetail.create(
        :course_teachership_id=>"123",
        :department_id=>"123",
        :view_times=>"0"
      )    
    end

    it "creates record" do 
      expect{
        unless @current_user.course_details.include?(@cd_to_add)
          @current_user.course_details << @cd_to_add
          msg= "新增成功!"
        else
          msg= "您已加入此課程"
        end
      }.to change(UserCourseDetailship ,:count).by 1
    end

    it "deletes record" do
      expect{
        if @current_user.course_details.include?(@cd_to_add)
          @current_user.course_details.delete(@cd_to_add)
          msg= "刪除成功!"
        else
          msg= "你未加入此課程!"
        end
      }.to change(UserCourseDetailship ,:count).by -1
    end
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
