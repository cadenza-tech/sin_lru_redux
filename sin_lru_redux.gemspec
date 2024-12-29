# frozen_string_literal: true

require_relative 'lib/lru_redux/version'

Gem::Specification.new do |spec|
  spec.name = 'sin_lru_redux'
  spec.version = LruRedux::VERSION
  spec.description = <<~DESCRIPTION
    Efficient and thread-safe LRU cache.
    Forked from LruRedux.
  DESCRIPTION
  spec.summary = 'Efficient and thread-safe LRU cache.'
  spec.authors = ['Masahiro']
  spec.email = ['watanabe@cadenza-tech.com']
  spec.license = 'MIT'

  github_root_uri = 'https://github.com/cadenza-tech/sin_lru_redux'
  spec.homepage = "#{github_root_uri}/tree/v#{spec.version}"
  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{github_root_uri}/blob/#{spec.version}#changelog",
    'bug_tracker_uri' => "#{github_root_uri}/issues",
    'documentation_uri' => "https://rubydoc.info/gems/#{spec.name}/#{spec.version}",
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 2.3.0'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
