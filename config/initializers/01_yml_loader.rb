FB_CONFIG = YAML.load_file(Rails.root.join("config/social_network.yml"))

module Facebook
	
  APP_ID = FB_CONFIG["facebook"]['app_id']
  SECRET = FB_CONFIG["facebook"]['secret']
end

E3_CONFIG = YAML.load_file(Rails.root.join("config/E3.yml"))

module E3
	
  URL = E3_CONFIG["prefix_url"]
  
end

APP_CONFIG = YAML.load_file(Rails.root.join("config/app.yml"))

module AndroidApp
	KEY = APP_CONFIG["key"]
end