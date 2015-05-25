require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Nctuplus
  class Application < Rails::Application
  #config.assets.enabled = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
	config.assets.paths << "#{Rails}/vendor/assets/fonts"
	config.time_zone = 'Taipei'
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    #config.i18n.default_locale = "zh-TW"

     I18n.enforce_available_locales = false

    
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
	config.middleware.use Rack::JSONP
	 # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
	
	# Enable the asset pipeline
    config.assets.enabled = true
    
		#config.autoload_paths += %W(#{config.root}/app/models)
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
