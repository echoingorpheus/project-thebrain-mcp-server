# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.1'

# Specify your gem's dependencies in thebrain_mcp_server.gemspec
gemspec

# Additional development dependencies not in gemspec

group :development, :test do
  gem 'dotenv', '~> 2.8'              # Environment variable management
  gem 'vcr', '~> 6.2'                 # HTTP interaction recording
  gem 'webmock', '~> 3.19'            # HTTP request mocking
end

group :development do
  gem 'yard', '~> 0.9'                # Documentation generator
end
