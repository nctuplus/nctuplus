# -*- encoding: utf-8 -*-
# stub: autoparse 0.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "autoparse"
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bob Aman"]
  s.date = "2013-03-26"
  s.description = "An implementation of the JSON Schema specification. Provides automatic parsing\nfor any given JSON Schema.\n"
  s.email = "bobaman@google.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://autoparse.rubyforge.org/"
  s.rdoc_options = ["--main", "README.md"]
  s.rubyforge_project = "autoparse"
  s.rubygems_version = "2.4.8"
  s.summary = "A parsing system based on JSON Schema."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, [">= 2.3.1"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<extlib>, [">= 0.9.15"])
      s.add_development_dependency(%q<rake>, [">= 0.9.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.11.0"])
      s.add_development_dependency(%q<launchy>, [">= 2.1.1"])
    else
      s.add_dependency(%q<addressable>, [">= 2.3.1"])
      s.add_dependency(%q<multi_json>, [">= 1.0.0"])
      s.add_dependency(%q<extlib>, [">= 0.9.15"])
      s.add_dependency(%q<rake>, [">= 0.9.0"])
      s.add_dependency(%q<rspec>, [">= 2.11.0"])
      s.add_dependency(%q<launchy>, [">= 2.1.1"])
    end
  else
    s.add_dependency(%q<addressable>, [">= 2.3.1"])
    s.add_dependency(%q<multi_json>, [">= 1.0.0"])
    s.add_dependency(%q<extlib>, [">= 0.9.15"])
    s.add_dependency(%q<rake>, [">= 0.9.0"])
    s.add_dependency(%q<rspec>, [">= 2.11.0"])
    s.add_dependency(%q<launchy>, [">= 2.1.1"])
  end
end
