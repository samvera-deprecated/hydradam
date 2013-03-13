class UserMailer < ActionMailer::Base
  default from: "no-reply@example.com"
  
  def file_online_notice(user, file)
    @user = user
    @file = file
    @url = sufia.generic_file_url(file)
    mail(:to => user.email, :subject => "File ready for download")
  end

end
