require "uri"

class UserMailer < Devise::Mailer
  def confirmation_instructions(record, token, options = {})
    @confirmation_url = confirmation_url_for(token)

    super(record, token, options.merge(template_path: "user_mailer"))
  end

  private

  def confirmation_url_for(token)
    frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    uri = URI.join("#{frontend_url.delete_suffix("/")}/", "hesap-dogrulama")
    uri.query = URI.encode_www_form(confirmation_token: token)
    uri.to_s
  end
end
