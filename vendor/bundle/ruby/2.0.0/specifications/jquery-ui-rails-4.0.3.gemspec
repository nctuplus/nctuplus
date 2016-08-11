# -*- encoding: utf-8 -*-
# stub: jquery-ui-rails 4.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-ui-rails"
  s.version = "4.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jo Liss"]
  s.date = "2013-05-18"
  s.description = "jQuery UI's JavaScript, CSS, and image files packaged for the Rails 3.1+ asset pipeline"
  s.email = ["joliss42@gmail.com"]
  s.homepage = "https://github.com/joliss/jquery-ui-rails"
  s.rubygems_version = "2.4.8"
  s.summary = "jQuery UI packaged for the Rails asset pipeline"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<jquery-rails>, [">= 0"])
      s.add_development_dependency(%q<json>, ["~> 1.7"])
    else
      s.add_dependency(%q<railties>, [">= 3.1.0"])
      s.add_dependency(%q<jquery-rails>, [">= 0"])
      s.add_dependency(%q<json>, ["~> 1.7"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.1.0"])
    s.add_dependency(%q<jquery-rails>, [">= 0"])
    s.add_dependency(%q<json>, ["~> 1.7"])
  end
end
