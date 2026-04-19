# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'json', '~> 2.7.6'
if RUBY_ENGINE == 'truffleruby' && RUBY_VERSION.start_with?('3.2.')
  gem 'minitest', '< 5.26.2'
else
  gem 'minitest'
end
gem 'rake'
gem 'rubocop'
gem 'rubocop-minitest'
gem 'rubocop-performance'
gem 'rubocop-rake'
gem 'timecop'
