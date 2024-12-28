# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lru_redux/version'

Gem::Specification.new do |spec|
  spec.name = 'sin_lru_redux'
  spec.version = LruRedux::VERSION
  spec.authors = ['Masahiro']
  spec.email = ['watanabe@cadenza-tech.com']
  spec.description = 'An efficient implementation of an lru cache'
  spec.summary = 'An efficient implementation of an lru cache'
  spec.homepage = 'https://github.com/cadenza-tech/sin_lru_redux'
  spec.license = 'MIT'
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 2.3.0'

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
