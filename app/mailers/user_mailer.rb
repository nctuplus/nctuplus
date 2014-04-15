class UserMailer < ActionMailer::Base
  default from: "tychien@cs.nctu.edu.tw"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.confirm.subject
  #
  def confirm(name,email,key)
    @activate_url = "http://140.113.166.130:7711/user/mail_confirm?key="<<key
	@name=name
	#@key=key
    mail(:to => email, :subject => "Registered")  
  end  
end
