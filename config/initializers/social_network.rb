CONFIG = YAML.load_file(Rails.root.join("config/social_network.yml"))#[Rails.env]

module Facebook
  APP_ID = CONFIG["facebook"]['app_id']
  SECRET = CONFIG["facebook"]['secret']
end

#module Twitter
#  --
#end