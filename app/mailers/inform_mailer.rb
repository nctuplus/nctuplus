class InformMailer < ActionMailer::Base
  default from: "NCTU+@plus.nctu.edu.tw"
	def course_import(mesg)
		@mesg=mesg
		mail(to: "t6847kimo@gmail.com", subject: "#{Time.now} 課程匯入通知")
	end
	def discuss_reply(sub_discuss)
		@sub_discuss=sub_discuss
		@discuss=@sub_discuss.discuss
		mail(to: @discuss.user.email, subject: "NCTU+文章回應通知:#{@discuss.title}")
	end
	def event_update(event)
		@event=event

		@event.followers.each do |user|
			mail(to: user.email, subject: "NCTU+[已關注]活動更新通知:#{@event.title}")
		end
		
		@event.attendees.each do |user|
			mail(to: user.email, subject: "NCTU+[已參加]活動更新通知:#{@event.title}")
		end
		
		mail(to: @event.user.email, subject: "NCTU+[主辦方]活動更新通知: #{@event.title}")
				
	end
end
