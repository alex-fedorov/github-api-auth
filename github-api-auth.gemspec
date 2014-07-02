# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github/api/auth/version'

Gem::Specification.new do |spec|
  spec.name          = "github-api-auth"
  spec.version       = Github::Api::Auth::VERSION
  spec.authors       = ["Alexey Fedorov"]
  spec.email         = ["alexey.fedorov@wimdu.com"]
  spec.summary       = %q{Usefull class to authenticate to github api just once and get authenticated Octokit::Client in return. OTP included.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "octokit"
  spec.add_runtime_dependency "highline"
end
