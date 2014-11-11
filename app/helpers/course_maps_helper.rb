module CourseMapsHelper

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
				sub_fields = course_field.course_fields
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
		credit_need = count_field_credit(cfg.course_fields)
		cfg.credit_need = (cfg.credit_need < credit_need) ? credit_need : cfg.credit_need
		cfg.field_need = (cfg.course_fields.count < cfg.field_need) ? cfg.course_fields.count : cfg.field_need
		cfg.save!
	end
=begin	
  def statistic_level1(map_id, cfg)
  	match = false
  	#course_field_group = CourseFieldGroup.find(fg_id)
  	result=[]
  	total_credit = 0
		user_courses=current_user.pass_courses.map{|c| c.course}
  	cfg.course_fields.each do |cf|
  		res = statistic_level2(map_id, user_courses,cfg, cf)
  		total_credit += res[:credit]
  		result.append({:cf_name=>cf.name, :match=>res[:match]}) 		
  	end
  	
  	if result.select{|s| s[:match]}.length >= cfg.field_need.to_i and total_credit >= cfg.credit_need.to_i  		
  		match = true 
  	end

		return match
	
  end	
=end
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
	
	def update_cs_cfids(course_map,user)
		course_fields = course_map.course_field_groups.includes(:course_fields)
						.map{|cfg|cfg.course_fields.includes(:course_field_lists)}.flatten
		
		user.all_courses.each do |cs|
			course_fields.each do |cf|
				if cf_search(cs, cf)
					cs.course_field_id = cf.id
					cs.save!
					next
				end
			end
		end
	end
	
	def cf_search(cs, cf)		
		if cf.field_type == 0	
			cf.course_fields.each do |sub_cf|
				if cf_search(cs, sub_cf)
					return true
				end
			end
			return false
		else
			courses = cf.courses#.select{|c|c==cs.course}#cf.course_field_lists.select{|l| l.course == cs.course}	
			if courses.include?(cs.course)
				return true
			else
				group_courses=cf.course_groups.includes(:courses).map{|g|g.courses}.flatten#.map{|g|g.id}
				#group_ids = cf.course_field_lists.select(:course_group_id).where("course_group_id IS NOT NULL").pluck(:course_group_id)#.map{|cfl| cfl.course_group_id}#.flatten#
				#courses=CourseGroup.includes(:courses).where(:id=>group_ids).map{|cg|cg.courses}.flatten
				if group_courses.include?(cs.course)
					return true
				end
			end
			return false
		end
	end
  
	def courses_join_cf(user_courses,cf)
		return user_courses.select{|pc|pc.course_field==cf}.map{|cs|cs.course}
	end
	
  
  def check_sub_field(cf)
  	sub_fields = cf.course_fields
  	if sub_fields.empty?
  		return
  	else
  		sub_fields.each do |sf|
  			# TO-DO 
  		end	
  	end
  end
  
  def statistic_table_cal77(cfg, user_simulation, user)
  	res = {}
  	user_courses = user_simulation.map{|s| s.course_detail.course}
  	course_group_heads = CourseGroup.all.includes(:course)

  		course_fields = []
  		cfg.course_fields.includes(:course_field_lists).each do |cf|
  		
  			course_field = {}
  			course_field[:cf_name] = cf.name
  			course_units = []
			show_all = (cfg.group_type==1 or cf.course_field_lists.count<=6)? true : true # 
			#Rails.logger.debug "[debug] " + user_simulation.map{|s| s.course_detail.course.ch_name}.to_s			
  			cf.course_field_lists.includes(:course).each do |list|
  				tmp = {}
  				tmp[:note] = ""	
  				match = true
  				user_courses = user_simulation.map{|s| s.course_detail.course}
  				if user_courses.include? list.course
  					target = user_simulation.select{|s| s.course_detail.course==list.course}.first	
  					Rails.logger.debug "[debug] " + user_simulation.select{|s| s.course_detail.course==list.course}.map{|s| s.score.to_s}.to_s
  					tmp[:course] = list.course	
  					tmp[:grade] = count_grade(user.semester, target.semester)
  					tmp[:score] = target.score
  					tmp[:note] += (cfg.group_type==3 and list.c_type==1)?"必選修 ":""
  					if tmp[:grade] ==0 and tmp[:score]=="通過"
  						tmp[:note] += "大學攜帶課程抵免 "
  					end
  					if tmp[:grade]==-1
  						tmp[:note] += "本學期修習中"
  					end
  					
  					user_simulation = user_simulation.reject{|s| s == target}
  				else
  					isHead = course_group_heads.select{|h| h.course==list.course}
  					if isHead.presence 
  						headContent = isHead.first.course_group_lists.map{|l| l.course}
  						match2 = headContent - (headContent - user_courses)
  						#Rails.logger.debug "[debug match] "+ match.to_s 						
  						if not match2.empty? #presence
  							target = user_simulation.select{|s| s.course_detail.course.id==match2[0].id}.first
  							#c+ user_simulation.map{|s| s.course_detail.course.id}.to_s
  							grade = count_grade(user.semester, target.semester)
  							if grade != 0
  								tmp[:course] = list.course
  								tmp[:grade] = grade
  								tmp[:score] = target.score
  								tmp[:note] += (cfg.group_type==3 and list.c_type==1)?"必選修 ":""
  								if tmp[:grade] ==0 and tmp[:score]=="通過"
  									tmp[:note] += "已抵免"
  								end								
  								tmp[:note] += target.course_detail.course.ch_name
  								if tmp[:grade]==-1
  									tmp[:note] += "本學期修習中"
  								end
								user_simulation = user_simulation.reject{|s| s == target}
  							else
  								match = false										
  							end
  						else
  							match = false							
  						end
  					else
  						match = false						
  					end
  				end
  			
  				if match
  					course_units.push(tmp)
  				else
  		#			check_sub_field(cf)    For inner layer
  					if show_all 
  						tmp[:course] = list.course
  						tmp[:grade] = 0
  						tmp[:score] = 0
  						tmp[:note] += (cfg.group_type==3 and list.c_type==1)?"必選修 ":""
  						course_units.push(tmp)
  					end
  					break
  				end	

  			end # each list
  			
  			
  			course_field[:course_units] = course_units
  			# course_field end
  			course_fields.push(course_field)
  		end
  			

  	res[:cfg_name] = cfg.name
  	res[:cfg_type] = cfg.group_type
  	res[:cf_info] = course_fields
  	res[:course_remaining] = user_simulation
    #Rails.logger.debug "[debug] " + user_simulation.map{|s| s.course_detail.course.ch_name}.to_s
  	return res
  end
  
  def statistic_table_cal(map_id, cfg, user_simulation, user)
  	res = {}
  	user_courses = user_simulation.map{|s| s.course_detail.course}
  	course_group_heads = CourseGroup.where("course_map_id=0 or course_map_id=?",map_id).includes(:course)

  		course_fields = []
  		cfg.course_fields.includes(:course_field_lists).each do |cf|	
  			course_field = {}
  			course_field[:cf_name] = cf.name
  			course_units = []
			show_all = (cfg.group_type==1 or cf.course_field_lists.count<=6)? true : false # 
			#Rails.logger.debug "[debug] " + user_simulation.map{|s| s.course_detail.course.ch_name}.to_s			
  			main = cf.course_field_lists.includes(:course) 

# handle sub field, only handle one layer and one child now
  			if not cf.course_fields.empty?
  				subs = cf.course_fields.last.course_field_lists.includes(:course)
  				main += subs
  			end
  			
  			main.each do |list|
  				user_courses = user_simulation.map{|s| s.course_detail.course}
  		#		Rails.logger.debug "[debug all] " + user_simulation.map{|s| s.course_detail.course.ch_name}.to_s
  				tmp = {}
  				tmp[:note] = ""	
  				tmp[:grade] = []
  				tmp[:score] = []
  				match = false
  				pass = true		
  				target1 = nil						
  				if user_simulation.map{|s| s.course_detail.course}.include? list.course
  		#		Rails.logger.debug "[debug] first match " + list.course.ch_name 
  		#       Rails.logger.debug "[debug] 11 " + user_simulation.map{|s| s.course_detail.course.ch_name}.to_s 			
  					target1 = user_simulation.select{|s| s.course_detail.course==list.course}.first	
  					tmp[:course] = list.course	
  					grade = count_grade(user.semester, target1.semester)
  					score = target1.score
  					tmp[:grade].push(grade)
  					tmp[:score].push(score)
  					tmp[:note] += ((cfg.group_type==3 and list.c_type==1)?"必選修 ":"")
  					if grade==0 and score=="通過"
  						tmp[:note] += "大學攜帶課程抵免"
  					elsif grade==-1
  						tmp[:note] += "本學期修習中"
  					end
  					check_res = check_pass(user, score)
  					tmp[:credit] = target1.course_detail.credit
  					tmp[:credit_get] = (check_res  and grade!=-1)?(target1.course_detail.credit):0
  					pass = (check_res)? true : false	
  					match = true	
  			#		Rails.logger.debug "[debug] res pass1 " + pass.to_s
  				end
  			#if not match or not pass	
  					isHead = course_group_heads.select{|h| h.course==list.course}
  					if not isHead.empty?
  		#				Rails.logger.debug "[debug In 2] " + isHead.first.course.ch_name+ " "+ isHead.first.course.id.to_s
  						headContent = isHead.first.course_group_lists.map{|l| l.course}
  						match2 = headContent - (headContent - user_courses)
  		#				Rails.logger.debug "[debug 2 match] "+headContent.to_s 						
  						if (not match2.empty?) #presence
  				#			Rails.logger.debug "[debug] 2 " + match2.to_s
  							match2.each do |m|
  								tmp[:course] = list.course
  								target = user_simulation.select{|s| s.course_detail.course==m}.first
  								grade = count_grade(user.semester, target.semester)
  								if grade >= 0												
  									check_res = check_pass(user, target.score)
  									if match and pass 
  										if not check_res # add all fail course
  											tmp[:grade].push(grade)
  											tmp[:score].push(target.score)
  											tmp[:note] += (cfg.group_type==3 and list.c_type==1)?"必選修 ":""
  											if grade==0 and target.score=="通過"
  												tmp[:note] += "已抵免"
  											end								
  											tmp[:note] += target.course_detail.course.ch_name+" "
  											if grade==-1
  												tmp[:note] += "本學期修習中"
  											end
											user_simulation = user_simulation.reject{|s| s == target}																	
  										else	
  											user_simulation = user_simulation.reject{|s| s == target1}								
  										end
  									else									
  										tmp[:grade].push(grade)
  										tmp[:score].push(target.score)
  										tmp[:note] += (cfg.group_type==3 and list.c_type==1)?"必選修 ":""
  										if grade==0 and target.score=="通過"
  											tmp[:note] += "已抵免"
  										end								
  										tmp[:note] += target.course_detail.course.ch_name+" "
  										if grade==-1
  											tmp[:note] += "本學期修習中"
  										end
										user_simulation = user_simulation.reject{|s| s == target}																			
										tmp[:credit] = target.course_detail.credit
  										tmp[:credit_get] = ((check_res and grade!=-1)?tmp[:credit]:0)								
  										match = true
  										if match and check_res
  											break
  										end
  									end							
  								end
  							end # match2 for each
  						else
  							if match
  								user_simulation = user_simulation.reject{|s| s == target1}
  							else
  								match = false
  							end							
  						end
  					else
  						if match
  							user_simulation = user_simulation.reject{|s| s == target1}
  						else
  							match = false	
  						end						
  					end
			#end# if match and pass
  	#			Rails.logger.debug "[debug] out 2 " + match.to_s
  				if match 
  					course_units.push(tmp)
  				else
  					if show_all 
  			#			Rails.logger.debug "[debug] res " + list.course.ch_name
  						tmp[:course] = list.course
  						tmp[:grade].push(0)
  						tmp[:score].push(0)
  						tmp[:credit] = list.course.course_details.first.credit
  						tmp[:credit_get] = 0
  						tmp[:note] += ((cfg.group_type==3 and list.c_type==1)?"必選修 ":"")
  						course_units.push(tmp)
  					end
  					#break
  				end	

  			end # each list
  			
  			course_field[:course_units] = course_units
  			# course_field end
  			course_fields.push(course_field)
  		end
  			

  	res[:cfg_name] = cfg.name
  	res[:cfg_type] = cfg.group_type
  	res[:cf_info] = course_fields
  	res[:course_remaining] = user_simulation
#    Rails.logger.debug "[debug] " + res.to_s
  	return res
  end
  
  def count_grade(me, target) # semester
	unless target # semester_id ==0 抵免
		return 0
	end
	if latest_semester == target
		return -1 # 本學期正在修
	end
	
	diff = target.name.to_i - me.name.to_i
	#Rails.logger.debug "[debug target] "+ target.name.to_s 	
	part = (target.name.include?"上")?0:1
	re = (diff>=0)?(diff*2+1+part):-2 # return -2 if 入學期修？
	#Rails.logger.debug "[debug count_grade] "+ re.to_s 
	return re
  end  
  
  def count_all_row(res)
  	count = 0
  	res[:cf_info].each do |cf|
  		count += cf[:course_units].count
  	end
  	return count.to_s
  end
  
  def check_pass(user, score)
  	if score=="通過"
  		return true	
  	elsif score=="W"
  		return false	
  	else
  #	Rails.logger.debug "[debug pass] deg=" + user.department.degree.to_s + " score="+score.to_s
  		if user.department.degree.to_i==3 and score.to_i>=60
  			return true	
  		elsif user.department.degree.to_i==2 and score.to_i>=70
  			return true	
  		end
  	end	
  	return false
  end	
  
  #def count_cfg_credit()	
  #	
  #end	
end
