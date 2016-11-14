# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/s3-shared-secrets/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-s3-shared-secrets"
  spec.version       = Capistrano::S3SharedSecrets::VERSION
  spec.authors       = ["Carlos Peñas"]
  spec.email         = ["carlos.penas@the-cocktail.com"]

  spec.summary       = %q{S3 backed secrets.yml sharing}
  spec.description   = %q{share secrets.yml across developers thru S3 bucket and made some secrets available on capistrano}
  spec.homepage      = "https://github.com/the-cocktail/capistrano-s3-shared-secrets"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "capistrano", ">= 3.4.0"
end
