# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mothra/version'

Gem::Specification.new do |spec|
  spec.name          = "mothra"
  spec.version       = Mothra::VERSION
  spec.authors       = ["Jin-Sih Lin"]
  spec.email         = ["linpct@gmail.com"]
  spec.summary       = %q{Mothra, a FreeBSD send-pr tool for bugzilla}
  spec.description   = %q{Mothra, a FreeBSD send-pr tool for bugzilla}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rodzilla"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
