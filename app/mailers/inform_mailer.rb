class InformMailer < ActionMailer::Base
  default from: "Nctu-Plus@localhost"
	def course_import(mesg)
		@mesg=mesg
		mail(to: "t6847kimo@gmail.com", subject: "#{Time.now} 課程匯入通知")
	end
end
