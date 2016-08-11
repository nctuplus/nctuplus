# -*- encoding: utf-8 -*-
# stub: brakeman 3.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "brakeman"
  s.version = "3.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Justin Collins"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDijCCAnKgAwIBAgIBATANBgkqhkiG9w0BAQUFADBFMQ8wDQYDVQQDDAZqdXN0\naW4xHTAbBgoJkiaJk/IsZAEZFg1wcmVzaWRlbnRiZWVmMRMwEQYKCZImiZPyLGQB\nGRYDY29tMB4XDTE1MDEwMzAxMjI0NFoXDTE2MDEwMzAxMjI0NFowRTEPMA0GA1UE\nAwwGanVzdGluMR0wGwYKCZImiZPyLGQBGRYNcHJlc2lkZW50YmVlZjETMBEGCgmS\nJomT8ixkARkWA2NvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMjt\nxjn8ArkEqQNrRjEeyZAOyr0O8+WZ54AcObsKg2osrcAW6iFd7tjnTFclQHmZgje+\ncwxeF/YG4PbA72ElmCvjn8vQJkdgHspKds1otSozvTF2VDnyAEg0nDTMgkQGQy4R\nHX3NHXMJ8UCAJv2IV/FsItzcPzPmhhf6vu/QaNrmAm3/nF52EsMSEJNC9eTPWudC\nkPgt19T9LRKMk5YbXDM6jWGRubusE03bTwY3RThqYM5ra1DwI/HpWKsKdmNrBbse\nf065WyR7RNAxindc2wMyq1EaInmO7Vds+rsOFZ4ZnO90z046ywmTLTadqlfuc9Qo\nCEw/AhYB6f6DLH8ICkMCAwEAAaOBhDCBgTAJBgNVHRMEAjAAMAsGA1UdDwQEAwIE\nsDAdBgNVHQ4EFgQUmIuIvxLr7ziB52LOpVgd694EfaEwIwYDVR0RBBwwGoEYanVz\ndGluQHByZXNpZGVudGJlZWYuY29tMCMGA1UdEgQcMBqBGGp1c3RpbkBwcmVzaWRl\nbnRiZWVmLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAbgSKdn/VSDdl5H2ayE+OM662\ngTJWP1CWfbcRVJW/UDjDucEF42t6V/dZTDmwyYTR8Qv+5FsQoPHsDsD3Jr1E62dl\nVYDeUkbmiV5f8fANbvnGUknzrHwp2T0/URxiIY8oFcaCGT+iua9zlNU20+XhB9JN\nfsOSUNBuuE/MYGA37MR1sP7lFHr5e7I1Qk1x3HvjNB/kSv1+Cj26Lde1ehvMqpmi\nbxoxp9KNxkO+709YwLO1rYfmcGghg8WV6MYz3PSHdlgWF4KrjRFc/00hXHqVk0Sf\nmREEv2LPwHH2SgpSSab+iawnX4l6lV8XcIrmp/HSMySsPVFBeOmB0c05LpEN8w==\n-----END CERTIFICATE-----\n"]
  s.date = "2015-04-30"
  s.description = "Brakeman detects security vulnerabilities in Ruby on Rails applications via static analysis."
  s.email = "gem@brakeman.org"
  s.executables = ["brakeman"]
  s.files = ["bin/brakeman"]
  s.homepage = "http://brakemanscanner.org"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Security vulnerability scanner for Ruby on Rails."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_runtime_dependency(%q<ruby_parser>, ["~> 3.6.2"])
      s.add_runtime_dependency(%q<ruby2ruby>, ["~> 2.1.1"])
      s.add_runtime_dependency(%q<terminal-table>, ["~> 1.4"])
      s.add_runtime_dependency(%q<fastercsv>, ["~> 1.5"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.6.20"])
      s.add_runtime_dependency(%q<erubis>, ["~> 2.6"])
      s.add_runtime_dependency(%q<haml>, ["< 5.0", ">= 3.0"])
      s.add_runtime_dependency(%q<sass>, ["~> 3.0"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.2"])
    else
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<ruby_parser>, ["~> 3.6.2"])
      s.add_dependency(%q<ruby2ruby>, ["~> 2.1.1"])
      s.add_dependency(%q<terminal-table>, ["~> 1.4"])
      s.add_dependency(%q<fastercsv>, ["~> 1.5"])
      s.add_dependency(%q<highline>, ["~> 1.6.20"])
      s.add_dependency(%q<erubis>, ["~> 2.6"])
      s.add_dependency(%q<haml>, ["< 5.0", ">= 3.0"])
      s.add_dependency(%q<sass>, ["~> 3.0"])
      s.add_dependency(%q<multi_json>, ["~> 1.2"])
    end
  else
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<ruby_parser>, ["~> 3.6.2"])
    s.add_dependency(%q<ruby2ruby>, ["~> 2.1.1"])
    s.add_dependency(%q<terminal-table>, ["~> 1.4"])
    s.add_dependency(%q<fastercsv>, ["~> 1.5"])
    s.add_dependency(%q<highline>, ["~> 1.6.20"])
    s.add_dependency(%q<erubis>, ["~> 2.6"])
    s.add_dependency(%q<haml>, ["< 5.0", ">= 3.0"])
    s.add_dependency(%q<sass>, ["~> 3.0"])
    s.add_dependency(%q<multi_json>, ["~> 1.2"])
  end
end
