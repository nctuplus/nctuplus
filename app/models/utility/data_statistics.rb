class DataStatistics
	# The website database statistics method

	def self.user_signup
		return User.select("created_at")
		.group("DATE_FORMAT((created_at),'%y年%m月')")
		.order("date(created_at)").count
	end

	def self.user_signin_protocol
		e3 = AuthE3.pluck(:user_id)
		fb = AuthFacebook.pluck(:user_id)
		return [(e3-fb).count, (fb-e3).count, (e3&fb).count]
	end

	def self.import_course_count
		return (NormalScore.uniq.pluck(:user_id) | AgreedScore.uniq.pluck(:user_id)).count
	end

end