# -*- encoding: utf-8 -*-
# stub: em-resolv-replace 1.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "em-resolv-replace"
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Mike Perham"]
  s.date = "2012-07-17"
  s.email = "mperham@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "History.rdoc", "README.rdoc"]
  s.files = ["History.rdoc", "LICENSE", "README.rdoc"]
  s.homepage = "http://github.com/mperham/em-resolv-replace"
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubygems_version = "2.4.8"
  s.summary = "EventMachine-aware DNS lookup for Ruby"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
