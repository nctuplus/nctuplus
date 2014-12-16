module ApiHelper
	def parse_scores(score)
		agree=[]
		normal=[]
		student_id=0
		student_name="" 
		dept=""
		score.split("\r\n").each do |s|
			s2=s.split("\t")
			if s2.length>3 && s2[2].match(/[[:digit:]]{5}+/)
				student_id=s2[2]
				dept=s2[0]
				student_name=s2[4]
			elsif s2.length>5 && s2[0].match(/[[:digit:]]/)
				#Rails.logger.debug "[debug] "+s2[1]
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					#Rails.logger.debug "[debug] "+s2[1]
					agree.append({:real_id=>s2[1], :credit=>s2[3].to_i, :memo=>s2[5], :name=>s2[2], :cos_type=>s2[4]||""})
				elsif s2[1].include?('.')
					course=course
				elsif s2[1].match(/[[:digit:]]{3}+/) && s2[2].match(/[[:digit:]]{4}/)
					course={'sem'=>s2[1], 'cos_id'=>s2[2], 'score'=>s2[7], 'name'=>s2[4], 'cos_type'=>s2[5]||""}
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
end
