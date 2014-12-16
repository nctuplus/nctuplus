OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :facebook, '272520269546220', '9dd6af5c70d6eac3d26e656e4b638fa3'
	provider :facebook, Facebook::APP_ID, Facebook::SECRET
end