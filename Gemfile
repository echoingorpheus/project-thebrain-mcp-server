# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.1'

# Core dependencies
gem 'concurrent-ruby', '~> 1.2'      # Thread-safe utilities
gem 'dry-configurable', '~> 1.1'     # Configuration management
gem 'faraday', '~> 2.7'              # HTTP client for TheBrain API
gem 'faraday-retry', '~> 2.2'        # Retry logic for HTTP requests
gem 'json', '~> 2.6'                 # JSON parsing
gem 'zeitwerk', '~> 2.6'             # Autoloading

group :development, :test do
  gem 'pry', '~> 0.14'                        # Debugging
  gem 'pry-byebug', '~> 3.10'                 # Debugging with breakpoints
  gem 'rspec', '~> 3.12'                      # Testing framework
  gem 'rspec-json_expectations', '~> 2.2'     # JSON expectations
  gem 'vcr', '~> 6.2'                         # HTTP interaction recording
  gem 'webmock', '~> 3.19'                    # HTTP request mocking
end

group :development do
  gem 'rubocop', '~> 1.57'                    # Code style checker
  gem 'rubocop-rspec', '~> 2.25'              # RSpec-specific rubocop rules
  gem 'solargraph', '~> 0.49'                 # Language server for IDE support
  gem 'yard', '~> 0.9'                        # Documentation generator
end

group :test do
  gem 'simplecov', '~> 0.22'                  # Code coverage
  gem 'simplecov-console', '~> 0.9'           # Console coverage output
end
