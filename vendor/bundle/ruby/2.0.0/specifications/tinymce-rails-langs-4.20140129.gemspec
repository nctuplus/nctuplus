# -*- encoding: utf-8 -*-
# stub: tinymce-rails-langs 4.20140129 ruby lib

Gem::Specification.new do |s|
  s.name = "tinymce-rails-langs"
  s.version = "4.20140129"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sam Pohlenz"]
  s.date = "2014-01-29"
  s.description = "Additional language packs for tinymce-rails."
  s.email = "sam@sampohlenz.com"
  s.homepage = "https://github.com/spohlenz/tinymce-rails-langs"
  s.rubygems_version = "2.4.8"
  s.summary = "Additional language packs for tinymce-rails."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tinymce-rails>, ["~> 4.0"])
    else
      s.add_dependency(%q<tinymce-rails>, ["~> 4.0"])
    end
  else
    s.add_dependency(%q<tinymce-rails>, ["~> 4.0"])
  end
end
