$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'linearly/version'

Gem::Specification.new do |spec|
  spec.name    = 'linearly'
  spec.version = Linearly::VERSION

  spec.author   = 'Marcin Wyszynski'
  spec.email    = 'marcinw [at] gmx.com'
  spec.summary  = 'Linear workflow framework based on immutable state'
  spec.homepage = 'https://github.com/marcinwyszynski/linearly'
  spec.license  = 'MIT'

  spec.files      = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_runtime_dependency 'statefully', '>= 0.1.5'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'ensure_version_bump'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'yardstick'

  spec.metadata['yard.run'] = 'yard'
end
