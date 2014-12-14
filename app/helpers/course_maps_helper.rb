module CourseMapsHelper

	def cf_trace(cf, funcA, funcB=nil)
  	    if cf.field_type < 3
			data = send(funcA, cf)	
		else 
			nodes = []
			cf.child_cfs.order('field_type ASC').each do |sub|
				nodes.push(cf_trace(sub, funcA, funcB))
			end
			data= send(funcB, cf, nodes) if funcB
		end
		return data
    end
	
	def statistic_map(map) # course_map header 
		group_list = map.course_field_groups
		msg = ""
		#必修
		must = 0
		group_list.select{|g| g.group_type==1}.each do |l|
			each_must = 0
			l.course_fields.first.course_field_lists.each do |ll|
				each_must += ll.course.course_details.first.credit.to_i
			end
			must+=each_must
			msg += "[必修學程] <b>"+l.course_fields.first.name+"</b> 	需修習 <b>"+each_must.to_s+"</b> 學分</br>"
		end
		#多選多
		multi = 0
		group_list.select{|g| g.group_type==2}.each do |l|
			each_multi = 0
			field_lists = l.course_fields.first.course_field_lists
			field_lists.select{|c| c.c_type==1}.each do |ll|
				each_multi += ll.course.course_details.first.credit.to_i
			end
			multi += l.course_fields.first.credit_need
			msg += "[多選多學程] "+l.course_fields.first.name+" 	共 <b>"+field_lists.count.to_s+"</b> 門課程可選擇，共需修習 <b>"+l.course_fields.first.credit_need.to_s+"</b> 學分</br>"
		end
		#領域
		field = 0
		group_list.select{|g| g.group_type==3}.each do |l|
			field += l.credit_need.to_i
			msg += "[領域學程] <b>"+l.name+"</b> 	總共需修習 <b>"+field.to_s+"</b> 學分  且至少需完成 <b>"+l.field_need.to_s+"</b> 個領域</br>"
		end
		
		res = must+multi+field
		msg += "==== 總共需要修習 <b class='text-color-red'>"+res.to_s+"</b> 學分 ====</br>"
		return msg
	end
	
	def course_field_must_credit_check(cf_id, group_type) # on update course_field.credit_need
		course_field = CourseField.find(cf_id)
		must_credit = 0

  		course_field.course_field_lists.select{|l| (l.c_type.to_i==1 and l.record_type==true)}.each do |fl|
  				must_credit += fl.course.course_details.first.credit.to_i
  		end
		if group_type==1 #必修 都必修
			course_field.credit_need = must_credit
			course_field.save!
#			Rails.logger.debug "[debug] " + must_credit.to_s
		else
			if group_type==3#領域 需多檢查子群組
				sub_fields = course_field.child_cfs
				unless sub_fields.empty?
					must_credit += sub_fields.sum(:credit_need).to_i	
				end	
			end
			
			if must_credit > course_field.credit_need.to_i
				course_field.credit_need = must_credit
				course_field.save!
			end		
		end
	end
	
	def count_field_credit(course_field)
		return course_field.sum(:credit_need)
	end
	
	def course_field_group_must_credit_check(cfg)
		credit_need = count_field_credit(cfg.child_cfs)
		cfg.credit_need = (cfg.credit_need < credit_need) ? credit_need : cfg.credit_need
		cfg.field_need = (cfg.child_cfs.count < cfg.field_need) ? cfg.child_cfs.count : cfg.field_need
		cfg.save!
	end

  def statistic_level2(map_id, user_courses, cf)
  	match = false

  	group_type = cf.field_type
  	target = cf.course_field_lists.includes(:course).map{|c| c.course}
  	unless cf.course_fields.empty?
  		sub_target = cf.course_fields.last.course_field_lists.includes(:course).map{|c| c.course}
  	end
  	
  	miss = target - user_courses
  	result = target - miss
  	org_result = Array.new(result)
  	cg = CourseGroup.where("course_map_id=?", map_id).includes(:course).map{|c| c.course} # course_group with a representative
  	
	# check course_group
  	miss.each do |m|
  		if cg.include? m   # miss is course_group representative
  			target_cg = CourseGroup.where(:course_id=>m.id).first.course_group_lists.includes(:course).map{|c| c.course}
  			unless (target_cg & user_courses).empty? # if has intersection
  				result.push(m) # add back to result
					org_result.push((target_cg & user_courses).first)
					miss.delete(m)
  			end
			
  		end
  	end
 	
  	user_credit = (result.presence) ? result.map{|course|course.course_details.first.credit.to_i}.reduce(:+) :0
  	
  	if group_type==1
  		if target == result
  			match = true	
  		end
  	elsif group_type==2
  		if user_credit >= cf.credit_need.to_i
  			match = true
  		end
  	else
		must = cf.course_field_lists.includes(:course).select{|c| c.c_type==1}.map{|c| c.course}
		if (must - result).empty?
			if user_credit >= cf.credit_need.to_i
  				match = true
  			end
  		else
		end
  	end
  
  	return {:match=>match, :result2=>result,:rest=>miss, :result=>result.map{|c| c.id}, :credit=>user_credit, :org_result=>org_result}
  end
	
  # input : courses, course_field	
  def validate_pass(user_courses, cf)
  		res = {}
  		case cf.field_type
  			when 1
  				remains = cf.courses - user_courses
  				res[:pass] = (remains.empty?) ? true : false
  			when 2
  				match = cf.courses - (cf.courses - user_courses)
  				if match.map{|m| m.credit.to_i}.reduce(:+) >= cf.credit_need
  					res[:pass] = true 
  				else
  					res[:pass] = false
  				end 
  			when 3
  				field_pass = 0
  				cf.child_cfs.each do |sub|
  					tmp = validate_pass(user_courses, sub)
  					if tmp[:pass]
  						field_pass +=1
  					end
  				end
  				res[:pass] = (field_pass >= cf.field_need) ? true : false
  			when 4
  				res[:pass] = true
  				cf.child_cfs.each do |sub|
  					tmp = validate_pass(user_courses, sub)
  					unless tmp[:pass]
  						res[:pass] = false
  						return res
  					end
  				end		
  		end		
  		return res
  end	
	
	# update cs cf_id, deep to level 2
	def update_cs_cfids(course_map,user)
		user.all_courses.each do |cs|
				cs.course_field_id=0
				cs.save
		end
		return if course_map.nil?
		return if user.all_courses.empty?
		course_fields = course_map.course_fields.includes(:child_cfs)
#Rails.logger.debug "[all_courses] "+user.all_courses.map{|cs| [cs.id, cs.course.ch_name]}.to_s
		all_courses=user.all_courses
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
	def get_cm_res(course_map)
		{
			:name=>course_map.name,
			:id=>course_map.id,
			:max_colspan=>course_map.course_fields.where(:field_type=>3).map{|cf|cf.child_cfs.count}.max||2,
			:cfs=>get_cm_tree(course_map)
		}
	end
	def _get_bottom_node(cf)		
  	data={
  		:id=>cf.id,
			:cf_name=>cf.name,
			:credit_need=>cf.credit_need,
			:cf_type=>cf.field_type,
			:courses=>_get_courses_struct(cf.courses),#.map{|c|{:name=>c.ch_name, :id=>c.id, :credit=>c.credit}},
			:course_groups=>cf.course_groups.where(:gtype=>0).includes(:courses).map{|cg|{
				:credit=> cg.lead_course.credit,
				:lead_course_name=>cg.lead_course.ch_name,
				:lead_course_id=>cg.lead_course.id,
				:lead_course=>cg.lead_course.to_json_for_stat,#_get_course_struct(cg.lead_course),
				:courses=>_get_courses_struct(cg.courses)#.map{
			}}
		}
		return data
  end
	def _get_middle_node(cf,nodes)		
		{
  		:id=>cf.id,
			:cf_name=>cf.name,
			:cf_type=>cf.field_type,
			:field_need=>cf.field_type==3 ? cf.field_need : cf.child_cfs.count,
			:credit_need=>cf.credit_need,
			:child_cf=>nodes
		}
  end

	def _get_courses_struct(courses)
		courses.map{|c|
			#_get_course_struct(c)
			c.to_json_for_stat
		}
	end
	def get_cm_tree(course_map)
		return course_map.course_fields.includes(:courses, :child_cfs).map{|cf|
			cf.field_type < 3 ? 
				_get_bottom_node(cf) : 
				_get_middle_node(cf,cf.child_cfs.includes(:courses).map{|child_cf|get_cf_tree(child_cf)})
		}

	end
	def get_cf_tree(cf)
		return cf_trace(cf,:_get_bottom_node,:_get_middle_node)
		
	end
end
