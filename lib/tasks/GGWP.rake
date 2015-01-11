# encoding: utf-8

require "#{Rails.root}/app/helpers/course_maps_helper"
include CourseMapsHelper

namespace :GGWP do

	desc "test1"
	task :test => :environment do 
require 'google/api_client'
		client  = Google::APIClient.new			
		client.authorization = Signet::OAuth2::Client.new(
 		 :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
 		 :audience             => 'https://accounts.google.com/o/oauth2/token',
 		 :scope                => 'https://www.googleapis.com/auth/analytics.readonly',
 		 :issuer               => 'u9510606@gmail.com',
  		 :signing_key          => Google::APIClient::PKCS12.load_key('/home/cwlo/api_key.p12', 'notasecret')
		).tap { |auth| auth.fetch_access_token! }

	#client.authorization.access_token = '2a8169c1473df1f1c8e4cde5a9f90656db5f3288'
		api_method = client.discovered_api('analytics','v3').data.ga.get
			
		# make queries
result = client.execute(:api_method => api_method, :parameters => {
  'ids'        => 'ga:90869594',
  'start-date' => Date.new(1970,1,1).to_s,
  'end-date'   => Date.today.to_s,
  'dimensions' => 'ga:rt:userType',
  'metrics'    => 'ga:rt:activeUsers',
})

puts result.data.rows.inspect	
	end

	
	desc "update those cf import fail"
	task :update_cf => :environment do 
		cg_ids = CourseGroupList.where(:updated_at=> DateTime.now.ago(24.hour)..DateTime.now)
		.map{|cgl| cgl.course_group_id}
		cm_ids = CourseGroup.where(:id=>cg_ids, :gtype=>1).map{|cg| cg.course_map_id }
		cm_ids.each do |cm_id|
			UserCoursemapship.where(:course_map_id=>cm_id)
			.map{|ucs| User.find(ucs.user_id)}.each do |u|
				p u.name
			end
		end
	end
	
end