# -*- encoding: utf-8 -*-
# stub: google-api-client 0.8.2 ruby lib

Gem::Specification.new do |s|
  s.name = "google-api-client"
  s.version = "0.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bob Aman", "Steven Bazyl"]
  s.date = "2015-01-10"
  s.description = "The Google API Ruby Client makes it trivial to discover and access supported APIs."
  s.email = "sbazyl@google.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "https://github.com/google/google-api-ruby-client/"
  s.licenses = ["Apache-2.0"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.4.8"
  s.summary = "The Google API Ruby Client makes it trivial to discover and access Google's REST APIs."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, ["~> 2.3"])
      s.add_runtime_dependency(%q<signet>, ["~> 0.6"])
      s.add_runtime_dependency(%q<faraday>, ["~> 0.9"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.10"])
      s.add_runtime_dependency(%q<autoparse>, ["~> 0.3"])
      s.add_runtime_dependency(%q<extlib>, ["~> 0.9"])
      s.add_runtime_dependency(%q<launchy>, ["~> 2.4"])
      s.add_runtime_dependency(%q<retriable>, ["~> 1.4"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<kramdown>, ["~> 1.5"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.9"])
    else
      s.add_dependency(%q<addressable>, ["~> 2.3"])
      s.add_dependency(%q<signet>, ["~> 0.6"])
      s.add_dependency(%q<faraday>, ["~> 0.9"])
      s.add_dependency(%q<multi_json>, ["~> 1.10"])
      s.add_dependency(%q<autoparse>, ["~> 0.3"])
      s.add_dependency(%q<extlib>, ["~> 0.9"])
      s.add_dependency(%q<launchy>, ["~> 2.4"])
      s.add_dependency(%q<retriable>, ["~> 1.4"])
      s.add_dependency(%q<activesupport>, [">= 3.2"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<yard>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<kramdown>, ["~> 1.5"])
      s.add_dependency(%q<simplecov>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<addressable>, ["~> 2.3"])
    s.add_dependency(%q<signet>, ["~> 0.6"])
    s.add_dependency(%q<faraday>, ["~> 0.9"])
    s.add_dependency(%q<multi_json>, ["~> 1.10"])
    s.add_dependency(%q<autoparse>, ["~> 0.3"])
    s.add_dependency(%q<extlib>, ["~> 0.9"])
    s.add_dependency(%q<launchy>, ["~> 2.4"])
    s.add_dependency(%q<retriable>, ["~> 1.4"])
    s.add_dependency(%q<activesupport>, [">= 3.2"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<yard>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<kramdown>, ["~> 1.5"])
    s.add_dependency(%q<simplecov>, ["~> 0.9"])
  end
end
