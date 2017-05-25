begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  puts 'RSpec not available'
end

task :yardstick do
  require 'yardstick/rake/verify'

  Yardstick::Rake::Verify
    .new { |task| task.threshold = 100 }
    .verify_measurements
end
