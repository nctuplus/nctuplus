require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Nctuplus
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = "zh-TW"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    config.time_zone = 'Taipei'

    config.middleware.use Rack::JSONP

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    # Enable the asset pipeline
    config.assets.enabled = true
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]
  end
end
