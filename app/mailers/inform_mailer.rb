class InformMailer < ApplicationMailer
  default from: "NCTU+@plus.nctu.edu.tw"
	def course_import(mesg)
		@mesg=mesg
		mail(to: "chc71340@gmail.com", subject: "#{Time.now} 課程匯入通知")
	end
	def discuss_reply(sub_discuss)
		@sub_discuss=sub_discuss
		@discuss=@sub_discuss.discuss
		mail(to: @discuss.user.email, subject: "NCTU+文章回應通知:#{@discuss.title}")
	end
	def event_update(event)
		@event=event

		@event.attendees.each do |user|
			mail(to: user.email, subject: "NCTU+活動更新通知:#{@event.title}")
		end
		
		mail(to: @event.user.email, subject: "NCTU+活動更新通知: #{@event.title}")
				
	end
end
