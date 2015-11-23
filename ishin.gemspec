# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ishin/version'

Gem::Specification.new do |spec|
  spec.name          = 'ishin'
  spec.version       = Ishin::Version::STRING
  spec.authors       = ['Eddy Luten']
  spec.email         = ['eddyluten@gmail.com']

  spec.summary       = 'Ishin is an object to hash converter.'
  spec.description   = 'Ishin converts objects into their Hash representations.'
  spec.homepage      = 'https://github.com/EddyLuten/ishin'
  spec.license       = 'MIT'
  spec.platform      = Gem::Platform::RUBY

  spec.files         = `git ls-files -z`.split("\x0").reject do |file|
    file.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'benchmark-ips',             '~> 2.3'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.8'
  spec.add_development_dependency 'rake',                      '~> 10.0'
  spec.add_development_dependency 'reek',                      '~> 3.7'
  spec.add_development_dependency 'rspec',                     '~> 3.4'
  spec.add_development_dependency 'rubocop',                   '~> 0.35.1'
end
