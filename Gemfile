# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

if RUBY_ENGINE == 'truffleruby' && RUBY_VERSION < '3.3'
  gem 'json', '~> 2.7.6'
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
