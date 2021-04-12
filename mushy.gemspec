lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mushy/version'

Gem::Specification.new do |s|
  s.name           = 'mushy'
  s.version        = '0.13.0'
  s.date           = '2020-11-23'
  s.summary        = 'Process streams of work using common modules.'
  s.description    = 'This tool assists in the creation and processing of workflows.'
  s.authors        = ['Darren Cauthon']
  s.email          = 'darren@cauthon.com'
  s.files          = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.executables    = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage       = 'https://cauthon.com'
  s.license        = 'MIT'

  s.add_development_dependency 'minitest', '~> 5'
  s.add_runtime_dependency 'sinatra', '~> 2.1'
  s.add_runtime_dependency 'symbolized', '~> 0.0.1'
  s.add_runtime_dependency 'thor', '~> 1.1'
  s.add_runtime_dependency 'liquid', '~> 5'
  s.add_runtime_dependency 'ferrum','~> 0.11'
  s.add_runtime_dependency 'nokogiri', '~> 1'
  s.add_runtime_dependency 'faraday', '~> 1'
  s.add_runtime_dependency 'pony', '~> 1.13'
  s.add_runtime_dependency 'daemons', '~> 1'
  s.add_runtime_dependency 'listen', '~> 3.5'
end
