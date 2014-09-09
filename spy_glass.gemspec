# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spy_glass/version'

Gem::Specification.new do |spec|
  spec.name          = 'spy_glass'
  spec.version       = SpyGlass::VERSION
  spec.authors       = ['Danny Whalen']
  spec.email         = ['daniel.r.whalen@gmail.com']
  spec.summary       = 'A utility for defining web content transformation proxies.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/codeforamerica/spy_glass'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1'

  spec.add_dependency 'activesupport', '~> 3.1'
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.9'
end
