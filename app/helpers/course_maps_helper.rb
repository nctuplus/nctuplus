module CourseMapsHelper

	# update cs cf_id, deep to level 2
	def update_cs_cfids(course_map,user)
		return if course_map.nil?
		
		cmship = UserCoursemapship.where(:user_id=>user.id, :course_map_id=>course_map.id).last
		cmship.update_attributes!(:need_update=>0)
		
		taked=user.normal_scores.includes(:course_detail, :course)
		agreed=user.agreed_scores.includes(:course)
		return if agreed.empty? && taked.empty?
		course_fields = course_map.course_fields.includes(:child_cfs)
		
		(taked+agreed).each do |cs|
			cf_id=0
			course_fields.each do |cf| # level 1
				cf_id=_cf_search(cs,cf)
				if cf_id!=0
					break
				end
			end		
			cs.course_field_id = cf_id
			cs.save!
		end
		agreed=agreed.select{|cs|cs.memo.include?("同意免修")}
		#taked=all_courses.select{|cs|cs.semester_id!=0}
		course_map.course_groups.where(:gtype=>1).each do |cg|
			agreed.each do |agree|
				next if !cg.courses.include?(agree.course)
				taked.each do |take|
					if cg.courses.include?(take.course)
						agree.memo="(以"+take.ch_name+"抵免)"+agree.memo
						agree.score=take.score
						agree.save!
						take.destroy!
						break
					end
				end
			end		
		end
	end
	
	# return cf_id if match ,else nil
	def _cf_search(cs, cf)
		if cf.field_type >= 3 #領域群組
			cf.child_cfs.each do |sub_cf|
				#return _cf_search(cs,sub_cf)
				cf_id=_cf_search(cs, sub_cf)
				if cf_id!=0
					return cf_id
				end
			end
			return 0
		else
			courses = cf.courses
			if courses.include?(cs.course)
				return cf.id
			else
				group_courses=cf.course_groups.includes(:courses).map{|g|g.courses}.flatten#.map{|g|g.id}
				if group_courses.include?(cs.course)
					return cf.id
				end
			end
			return 0
		end
		#return 0
	end
  
	def courses_join_cf(user_courses,cf)
		return user_courses.select{|pc|pc.course_field==cf}.map{|cs|cs.course}
	end

end

