OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :facebook, Facebook::APP_ID, Facebook::SECRET
end