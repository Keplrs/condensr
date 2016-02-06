# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'condensr/version'

Gem::Specification.new do |spec|
  spec.name          = "condensr"
  spec.version       = Condensr::VERSION
  spec.authors       = ["Olalekan Sogunle"]
  spec.email         = ["sogunleolalekan@gmail.com"]

  spec.summary       = "TO upload files directly to cloud storage from the internet"
  spec.description   = "TO upload files directly to cloud storage from the internet"
  spec.homepage      = "http://rubygems.org/gems/condensr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "dotenv"
  spec.add_dependency "httparty", "~> 0.13.7"
  spec.add_dependency "aws-sdk", "~> 2"
  spec.add_dependency "gcloud"
end
