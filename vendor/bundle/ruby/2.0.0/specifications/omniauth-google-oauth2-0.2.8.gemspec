# -*- encoding: utf-8 -*-
# stub: omniauth-google-oauth2 0.2.8 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-google-oauth2"
  s.version = "0.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Josh Ellithorpe", "Yury Korolev"]
  s.date = "2015-10-01"
  s.description = "A Google OAuth2 strategy for OmniAuth 1.x"
  s.email = ["quest@mac.com"]
  s.homepage = "https://github.com/zquestz/omniauth-google-oauth2"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A Google OAuth2 strategy for OmniAuth 1.x"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth>, [">= 1.1.1"])
      s.add_runtime_dependency(%q<omniauth-oauth2>, [">= 1.1.1"])
      s.add_runtime_dependency(%q<jwt>, ["~> 1.0"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.3"])
      s.add_runtime_dependency(%q<addressable>, ["~> 2.3"])
      s.add_development_dependency(%q<rspec>, [">= 2.14.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<omniauth>, [">= 1.1.1"])
      s.add_dependency(%q<omniauth-oauth2>, [">= 1.1.1"])
      s.add_dependency(%q<jwt>, ["~> 1.0"])
      s.add_dependency(%q<multi_json>, ["~> 1.3"])
      s.add_dependency(%q<addressable>, ["~> 2.3"])
      s.add_dependency(%q<rspec>, [">= 2.14.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<omniauth>, [">= 1.1.1"])
    s.add_dependency(%q<omniauth-oauth2>, [">= 1.1.1"])
    s.add_dependency(%q<jwt>, ["~> 1.0"])
    s.add_dependency(%q<multi_json>, ["~> 1.3"])
    s.add_dependency(%q<addressable>, ["~> 2.3"])
    s.add_dependency(%q<rspec>, [">= 2.14.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
