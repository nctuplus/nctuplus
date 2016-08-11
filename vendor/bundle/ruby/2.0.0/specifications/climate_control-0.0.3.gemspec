# -*- encoding: utf-8 -*-
# stub: climate_control 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "climate_control"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Joshua Clayton"]
  s.date = "2012-11-30"
  s.description = "Modify your ENV"
  s.email = ["joshua.clayton@gmail.com"]
  s.homepage = "https://github.com/thoughtbot/climate_control"
  s.rubygems_version = "2.4.8"
  s.summary = "Modify your ENV easily with ClimateControl"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.11"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0"])
      s.add_dependency(%q<rspec>, ["~> 2.11"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0"])
    s.add_dependency(%q<rspec>, ["~> 2.11"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
    s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
  end
end
