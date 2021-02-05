lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mushy/version'

Gem::Specification.new do |s|
  s.name           = 'mushy'
  s.version        = '0.1.2'
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

  s.add_development_dependency 'minitest'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'symbolized'
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'liquid'
  s.add_runtime_dependency 'ferrum'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'faraday'
end
