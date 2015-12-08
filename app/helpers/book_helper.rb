module BookHelper
	def elapse_time(t)
		elapse = Time.now - t 
		if elapse > 1.month
			return "約#{(elapse/1.month).to_i}個月前"
		elsif elapse > 1.day
			return "約#{(elapse/1.day).to_i}天前"
		elsif elapse > 1.hour
			return "約#{((elapse%1.day)/1.hour).to_i}小時前"
		else
			return "約#{((elapse%1.hour)/1.minute).to_i}分鐘前"
		end
	end
end
