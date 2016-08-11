# -*- encoding: utf-8 -*-
# stub: tinymce-rails 4.2.8 ruby lib

Gem::Specification.new do |s|
  s.name = "tinymce-rails"
  s.version = "4.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sam Pohlenz"]
  s.date = "2015-11-13"
  s.description = "Seamlessly integrates TinyMCE into the Rails asset pipeline introduced in Rails 3.1."
  s.email = "sam@sampohlenz.com"
  s.homepage = "https://github.com/spohlenz/tinymce-rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Rails asset pipeline integration for TinyMCE."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.1.1"])
    else
      s.add_dependency(%q<railties>, [">= 3.1.1"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.1.1"])
  end
end
