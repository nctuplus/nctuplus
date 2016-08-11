# -*- encoding: utf-8 -*-
# stub: signet 0.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "signet"
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bob Aman", "Steven Bazyl"]
  s.date = "2014-12-05"
  s.description = "Signet is an OAuth 1.0 / OAuth 2.0 implementation.\n"
  s.email = "sbazyl@google.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "https://github.com/google/signet/"
  s.licenses = ["Apache-2.0"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.4.8"
  s.summary = "Signet is an OAuth 1.0 / OAuth 2.0 implementation."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, ["~> 2.3"])
      s.add_runtime_dependency(%q<faraday>, ["~> 0.9"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.10"])
      s.add_runtime_dependency(%q<jwt>, ["~> 1.0"])
      s.add_runtime_dependency(%q<extlib>, ["~> 0.9"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<launchy>, ["~> 2.4"])
      s.add_development_dependency(%q<kramdown>, ["~> 1.5"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.9"])
    else
      s.add_dependency(%q<addressable>, ["~> 2.3"])
      s.add_dependency(%q<faraday>, ["~> 0.9"])
      s.add_dependency(%q<multi_json>, ["~> 1.10"])
      s.add_dependency(%q<jwt>, ["~> 1.0"])
      s.add_dependency(%q<extlib>, ["~> 0.9"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<yard>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<launchy>, ["~> 2.4"])
      s.add_dependency(%q<kramdown>, ["~> 1.5"])
      s.add_dependency(%q<simplecov>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<addressable>, ["~> 2.3"])
    s.add_dependency(%q<faraday>, ["~> 0.9"])
    s.add_dependency(%q<multi_json>, ["~> 1.10"])
    s.add_dependency(%q<jwt>, ["~> 1.0"])
    s.add_dependency(%q<extlib>, ["~> 0.9"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<yard>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<launchy>, ["~> 2.4"])
    s.add_dependency(%q<kramdown>, ["~> 1.5"])
    s.add_dependency(%q<simplecov>, ["~> 0.9"])
  end
end
