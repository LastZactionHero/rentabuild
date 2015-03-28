class ContactMailer < ActionMailer::Base

  def contact_us_received(name, email, phone, message)
    @name = name
    @email = email
    @phone = phone
    @message = message

    mail(subject: "Contact Us Email Received", to: "zach@rentabuild.com")
  end

end