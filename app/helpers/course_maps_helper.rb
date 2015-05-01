module CourseMapsHelper

	# update cs cf_id, deep to level 2
	def update_cs_cfids(course_map,user)
		#user.all_courses.each do |cs|
		#		cs.course_field_id=0
		#		cs.save
		#end
		return if course_map.nil?
		return if user.all_courses.empty?
		course_fields = course_map.course_fields.includes(:child_cfs)
#Rails.logger.debug "[all_courses] "+user.all_courses.map{|cs| [cs.id, cs.course.ch_name]}.to_s
		all_courses=user.all_courses#.select{|cs|cs.course_field_id==0}
		all_courses.each do |cs|
			
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
		agreed=all_courses.select{|cs|cs.semester_id==0&&cs.memo.include?("同意免修")}
		taked=all_courses.select{|cs|cs.semester_id!=0}
		course_map.course_groups.where(:gtype=>1).each do |cg|
			agreed.each do |agree|
				#match_fail = true
				next if !cg.courses.include?(agree.course)
				taked.each do |take|
					if cg.courses.include?(take.course)
						agree.memo="("+take.course.ch_name+")"+agree.memo
						agree.score=take.score
						agree.save!
						take.destroy!
						#match_fail = false
						break
					end
				end
				#if match_fail
				#	agree.import_fail = 1 
				#	agree.save!
				#end
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

