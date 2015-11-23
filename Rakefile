require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'reek/rake/task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
Reek::Rake::Task.new

task :bench do
  sh 'ruby ./benchmarks/simple_bench.rb'
  sh 'ruby ./benchmarks/recursive_bench.rb'
  sh 'ruby ./benchmarks/symbolize_bench.rb'
end

task :default do
  Rake::Task[:rubocop].invoke
  Rake::Task[:spec].invoke
  Rake::Task[:reek].invoke
end
