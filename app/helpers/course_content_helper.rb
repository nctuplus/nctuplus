module CourseContentHelper
	def numeric?(lookAhead)
  		lookAhead =~ /[[:digit:]]/
	end
end
