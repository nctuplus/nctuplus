# -*- encoding: utf-8 -*-
# stub: rack-jsonp-middleware 0.0.10 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-jsonp-middleware"
  s.version = "0.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Roberto Decurnex"]
  s.date = "2014-08-04"
  s.description = "A Rack JSONP middleware"
  s.email = "decurnex.roberto@gmail.com"
  s.homepage = "http://robertodecurnex.github.com/rack-jsonp-middleware"
  s.rubygems_version = "2.4.8"
  s.summary = "rack-jsonp-middleware-0.0.5"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.3.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<coveralls>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.3.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<coveralls>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.3.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
