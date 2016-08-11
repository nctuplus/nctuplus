# -*- encoding: utf-8 -*-
# stub: koala 1.10.1 ruby lib

Gem::Specification.new do |s|
  s.name = "koala"
  s.version = "1.10.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Alex Koppel"]
  s.date = "2014-09-03"
  s.description = "Koala is a lightweight, flexible Ruby SDK for Facebook.  It allows read/write access to the social graph via the Graph and REST APIs, as well as support for realtime updates and OAuth and Facebook Connect authentication.  Koala is fully tested and supports Net::HTTP and Typhoeus connections out of the box and can accept custom modules for other services."
  s.email = "alex@alexkoppel.com"
  s.extra_rdoc_files = ["readme.md", "changelog.md"]
  s.files = ["changelog.md", "readme.md"]
  s.homepage = "http://github.com/arsduo/koala"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Koala"]
  s.rubygems_version = "2.4.8"
  s.summary = "A lightweight, flexible library for Facebook with support for the Graph API, the REST API, realtime updates, and OAuth authentication."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<faraday>, [">= 0"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
    else
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<faraday>, [">= 0"])
      s.add_dependency(%q<addressable>, [">= 0"])
    end
  else
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<faraday>, [">= 0"])
    s.add_dependency(%q<addressable>, [">= 0"])
  end
end
