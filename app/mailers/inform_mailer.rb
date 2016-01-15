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
end
