# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |task|
  task.pattern = 'test/**/test_*.rb'
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--format', ENV['RUBOCOP_FORMAT']] if ENV['RUBOCOP_FORMAT']
end
