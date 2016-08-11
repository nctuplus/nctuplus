# -*- encoding: utf-8 -*-
# stub: code_analyzer 0.4.5 ruby lib

Gem::Specification.new do |s|
  s.name = "code_analyzer"
  s.version = "0.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Richard Huang"]
  s.date = "2014-03-31"
  s.description = "a code analyzer tool which extracted from rails_best_practices, it helps you easily build your own code analyzer tool."
  s.email = ["flyerhzm@gmail.com"]
  s.homepage = "https://github.com/flyerhzm/code_analyzer"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "a code analyzer helps you build your own code analyzer tool."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sexp_processor>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<sexp_processor>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<sexp_processor>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
