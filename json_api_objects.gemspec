# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_api_objects/version'

Gem::Specification.new do |spec|
  spec.name          = 'json_api_objects'
  spec.version       = JsonApiObjects::VERSION
  spec.authors       = ['Maikel Lammers']
  spec.email         = ['maikel.lammers@gmx.de']

  spec.summary       = 'Creates api return objects, based on json schema.'
  spec.description   = ''
  spec.homepage      = "https://github.com/mlammers/json_api_objects"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'json-schema', '~> 2.0.0'
  spec.add_runtime_dependency 'json'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
