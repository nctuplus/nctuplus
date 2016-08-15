#require 'spec_helper'
require 'rails_helper'
#require 'user'

RSpec.describe User, :type=> :model do
	before(:all) do
		ActiveRecord::Base.connection.execute("TRUNCATE users")
		ActiveRecord::Base.connection.execute("TRUNCATE auth_facebooks")
		ActiveRecord::Base.connection.execute("TRUNCATE auth_e3s")
		ActiveRecord::Base.connection.execute("TRUNCATE discusses")
		ActiveRecord::Base.connection.execute("TRUNCATE normal_scores")
		ActiveRecord::Base.connection.execute("TRUNCATE agreed_scores")
		@e3_user=create_e3_user
		@fb_user=create_fb_user
		
	end

	it "merge" do
		@e3_user.discusses.create!(:title=>"E3",:content=>"Create from E3", :course_teachership_id=>7878)
		@e3_user.normal_scores.create!(:course_detail_id=>21474,:score=>"E3成績")
		@e3_user.agreed_scores.create!(:course_id=>5566,:score=>"E3成績")
		@fb_user.discusses.create!(:title=>"fACEBOOK",:content=>"Create from fb", :course_teachership_id=>8787)
		@fb_user.normal_scores.create!(:course_detail_id=>21747,:score=>"FB成績")
		@fb_user.agreed_scores.create!(:course_id=>3344,:score=>"FB成績")
		@e3_user.merge_child_to_newuser(@fb_user) #e3 merge to fb user,then delete e3 user
		expect {@e3_user.reload}.to raise_exception(ActiveRecord::RecordNotFound) #.reload
		expect(@fb_user.discusses.count).to eq(3)
		#puts @e3_user.id
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
	def create_fb_user
		puts "Creating Fb user"
		user=User.create(
			:name=>"FB user",
			:email=>"FB@ggmail.com",
			:encrypted_password=>"12345678",
			:sign_in_count=>0
		)
		user.create_auth_facebook(:name=>"facebook",:uid=>"12345678")
		return user
	end
end