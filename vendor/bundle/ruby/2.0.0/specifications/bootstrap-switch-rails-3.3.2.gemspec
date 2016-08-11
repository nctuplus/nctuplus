# -*- encoding: utf-8 -*-
# stub: bootstrap-switch-rails 3.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "bootstrap-switch-rails"
  s.version = "3.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Manuel van Rijn"]
  s.date = "2015-01-27"
  s.description = "A small gem for putting bootstrap-switch into the Rails asset pipeline"
  s.email = ["manuel@manuelles.nl"]
  s.homepage = "https://github.com/manuelvanrijn/bootstrap-switch-rails"
  s.licenses = ["MIT, Apache License v2.0"]
  s.rubygems_version = "2.4.8"
  s.summary = "an asset gemification of the bootstrap-switch plugin"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
