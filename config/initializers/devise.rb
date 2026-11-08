require "devise/orm/active_record"
require Rails.root.join("lib/api_authentication_failure")

Devise.setup do |config|
  config.mailer_sender = ENV.fetch("MAILER_FROM", "noreply@eistatistik.com")
  config.mailer = "UserMailer"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.paranoid = true
  config.skip_session_storage = [ :http_auth ]

  config.stretches = Rails.env.test? ? 1 : 12
  config.send_email_changed_notification = true
  config.send_password_change_notification = true

  config.allow_unconfirmed_access_for = 0.days
  config.confirm_within = 3.days
  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 12..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.timeout_in = 2.hours
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :both
  config.maximum_attempts = 10
  config.unlock_in = 1.hour
  config.last_attempt_warning = true

  config.reset_password_within = 2.hours
  config.sign_in_after_reset_password = false

  # API clients receive HTTP status codes instead of HTML redirects.
  config.navigational_formats = []
  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other

  config.warden do |manager|
    manager.failure_app = ApiAuthenticationFailure
  end
end
