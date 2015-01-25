# encoding: utf-8

require "#{Rails.root}/app/helpers/course_maps_helper"
include CourseMapsHelper

namespace :GGWP do

	desc "test1"
	task :test => :environment do 
require 'google/api_client'
		client  = Google::APIClient.new(:application_name=>'API Project', :application_version=>'1.0')
		client.authorization = Signet::OAuth2::Client.new(
 		 :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
 		 :audience             => 'https://accounts.google.com/o/oauth2/token',
 		 :scope                => 'https://www.googleapis.com/auth/analytics.readonly',
 		 :issuer               => '404775705851-hrp706vcd49ogh08guig2m4ta2jbmub3@developer.gserviceaccount.com',
  	 :signing_key          => Google::APIClient::PKCS12.load_key('/home/cwlo/api_key.p12', 'notasecret')
		).tap { |auth| auth.fetch_access_token! }
		api_method = client.discovered_api('analytics','v3').data.realtime.get
			
		# make queries
		result = client.execute(:api_method => api_method, :parameters => {
			'ids'        => 'ga:90869594',
			'dimensions' => 'rt:userType',
			'metrics'    => 'rt:activeUsers'
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