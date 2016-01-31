module UserHelper

	def parse_scores(score)	#for import course from 註冊組
		agree=[]
		normal=[]
		student_id=0
		student_name="" 
		dept=""
		score.split("\r\n").each do |s|	#split row
			s2=s.split("\t")
			if s2.length>3 && s2[2].match(/[[:digit:]]{5}+/)	#split column
				student_id=s2[2].delete(' ') #for Firefox
				dept=s2[0]
				student_name=s2[4]
			elsif s2.length>5 && s2[0].match(/[[:digit:]]/)
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					agree.append({
						:real_id=>s2[1],
						:credit=>s2[3].to_i,
						:memo=>s2[5],
						:ch_name=>s2[2],
						:cos_type=>s2[4]||""
					})
				elsif s2[1].match(/[[:digit:]]{3}+/) && s2[2].match(/[[:digit:]]{4}/)
					course={
						'sem'=>s2[1],
						'cos_id'=>s2[2],
						'score'=>s2[7].delete(' '), #for Firefox
						'name'=>s2[4],
						'cos_type'=>s2[5]||""
					}
					normal.append(course)
				end	
			end 
		end
		return {
			:student_id=>student_id,
			:student_name=>student_name,
			:agreed=>agree,
			:taked=>normal,
			:dept=>dept
		}
	end
	
	def grade_on_user(user, semester)	#for user/share & user/collections
	  dy = semester.year - user.year
	  dhalf = semester.half 
	  half_name = (dhalf==1) ? "上" : "下"
	  case dy
	    when 0
	      year_name = "一"
	    when 1
	      year_name = "二"
	    when 2
	      year_name = "三"
	    else
	      year_name = "四"    
	  end
	  grade_name = user.department.degree==3 ? "大" : "研"
	  return grade_name+year_name+half_name
	end
	
# user share	
	def can_add_to_collection?(current_user, user, semester)
		return (current_user.present? and current_user != user and !current_user.hasCollection?(user.id, semester.id))
	end	
	
	def generate_share_hashid(user_id, sem_id)
	  return Hashid.user_share_encode [user_id, sem_id]
	end
	
end
