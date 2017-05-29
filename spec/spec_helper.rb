require 'bundler/setup'
Bundler.setup

require 'pry'

if ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start { add_filter '/spec/' }

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'linearly'

require 'dynamic_step'
require 'static_step'
require 'test_step'
