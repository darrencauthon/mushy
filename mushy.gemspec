lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mushy/version'

Gem::Specification.new do |s|
  s.name        = 'mushy'
  s.version     = '0.0.1'
  s.date        = '2020-11-23'
  s.summary     = 'Mushy'
  s.description = 'Mushy'
  s.authors     = ['Darren Cauthon']
  s.email       = 'darren@cauthon.com'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.homepage    = 'https://cauthon.com'
  s.license     = 'MIT'

  s.add_development_dependency 'minitest'
end