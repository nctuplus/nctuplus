require "rails"
require "bootstrap-switch-rails/version"

module Bootstrap
  module Switch
    module Rails
      if ::Rails.version < "3.1"
        require "bootstrap-switch-rails/railtie"
      else
        require "bootstrap-switch-rails/engine"
      end
    end
  end
end
