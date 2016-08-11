# -*- encoding: utf-8 -*-
# stub: googlebooks 0.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "googlebooks"
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Zean Tsoi"]
  s.date = "2014-07-22"
  s.description = "GoogleBooks is a lightweight Ruby wrapper that queries the Google API to search for publications in the Google Books repository. It is inspired by the google-book gem which relies on the deprecated Google GData Books API, but is updated to hook into the current Google API."
  s.email = ["zean.tsoi@gmail.com"]
  s.homepage = "https://github.com/zeantsoi/googlebooks"
  s.rubyforge_project = "googlebooks"
  s.rubygems_version = "2.4.8"
  s.summary = "GoogleBooks is a lightweight Ruby wrapper that queries the Google API to search for publications in the Google Books repository."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<rspec-its>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<rspec-its>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<rspec-its>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
