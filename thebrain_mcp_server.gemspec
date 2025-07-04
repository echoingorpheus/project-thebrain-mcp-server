# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'thebrain_mcp_server'
  spec.version = '1.0.0'
  spec.authors = ['Roberto Nogueira']
  spec.email = ['enogrob@gmail.com']

  spec.summary = 'Model Context Protocol server for TheBrain integration'
  spec.description = 'A Ruby implementation of an MCP server that provides AI assistants with access to TheBrain knowledge management system'
  spec.homepage = 'https://github.com/enogrob/thebrain-mcp-server-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'concurrent-ruby', '~> 1.2'
  spec.add_dependency 'dry-configurable', '~> 1.1'
  spec.add_dependency 'dry-logger', '~> 1.0'
  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'faraday-retry', '~> 2.2'
  spec.add_dependency 'json', '~> 2.6'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # Development dependencies
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'pry-byebug', '~> 3.10'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rspec-json_expectations', '~> 2.2'
  spec.add_development_dependency 'rubocop', '~> 1.57'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.25'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-console', '~> 0.9'
  spec.add_development_dependency 'solargraph', '~> 0.49'
  spec.add_development_dependency 'vcr', '~> 6.2'
  spec.add_development_dependency 'webmock', '~> 3.19'
  spec.add_development_dependency 'yard', '~> 0.9'
end
