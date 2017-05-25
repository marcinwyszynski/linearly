require 'bundler/setup'
Bundler.setup

require 'pry'

if ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'linearly'

require 'static_step'
require 'test_step'
