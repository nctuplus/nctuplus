# encoding: utf-8

require "#{Rails.root}/app/helpers/course_maps_helper"
include CourseMapsHelper

namespace :GGWP do
	desc "testaa"
	task :test => :environment do 
		
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