# frozen_string_literal: true

require_relative 'lib/philiprehberger/duration/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-duration'
  spec.version       = Philiprehberger::Duration::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Immutable Duration value object — parse human strings and ISO 8601, ' \
                       'perform arithmetic and comparison, and format output'
  spec.description   = 'Parse human strings and ISO 8601 durations, perform arithmetic and comparison, ' \
                       'and output to human-readable or ISO 8601 formats.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-duration'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
