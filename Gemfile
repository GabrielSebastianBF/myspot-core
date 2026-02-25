source "https://rubygems.org"

ruby ">= 3.2.0"

gem "rails", "~> 7.2.0"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]

# MySpot Specific Gems
gem "pgvector" # Para embeddings
gem "anyway_config" # Configuración flexible
gem "pagy" # Paginación
gem "sidekiq" # Jobs async

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
