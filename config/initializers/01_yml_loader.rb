FB_CONFIG = YAML.load_file(Rails.root.join("config/social_network.yml"))

module Facebook	
  APP_ID = FB_CONFIG["facebook"]['app_id']
  SECRET = FB_CONFIG["facebook"]['secret']
end

module Google	
  APP_ID = FB_CONFIG["google"]['client_id']
  SECRET = FB_CONFIG["google"]['client_secret']
end

NCTU_CONFIG = YAML.load_file(Rails.root.join("config/nctu.yml"))

module E3
  URL = NCTU_CONFIG["E3"]["prefix_url"]
end

module NCTUOAUTH
  APP_ID = NCTU_CONFIG["OAUTH"]['client_id']
  SECRET = NCTU_CONFIG["OAUTH"]['secret']
  SITE = NCTU_CONFIG["OAUTH"]['site']
  AUTH_URL = NCTU_CONFIG["OAUTH"]['authorize_url']
  GET_TOKEN_URL = NCTU_CONFIG["OAUTH"]['get_token_url']
  API_PROFILE_URL = NCTU_CONFIG["OAUTH"]['api_profile_url']
end


APP_CONFIG = YAML.load_file(Rails.root.join("config/app.yml"))

module AndroidApp
	KEY = APP_CONFIG["key"]
end
