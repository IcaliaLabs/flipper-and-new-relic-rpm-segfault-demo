source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

################################################################################
# Gems involved in the demo ####################################################
################################################################################

# The New Relic Ruby Process Monitor:
gem 'newrelic_rpm', '~> 6.7', '>= 6.7.0.359'

# The base feature flag library:
gem 'flipper', '~> 0.17.1'

# Use activerecord to store the flipper feature toggles:
gem 'flipper-active_record', '~> 0.17.1'

################################################################################
################################################################################
################################################################################

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false


################################################################################
# Other Gems present on the project we first observed the segfaults ############
################################################################################

# Nested forms, for accepts_nested_attributes_for (Do not abuse!)
gem 'cocoon'
gem 'webpacker', '~> 3.5'
gem 'image_processing'
gem 'active_storage_validations'

gem 'chart-js-rails'
gem 'momentjs-rails'
# Dynamic color generation
gem 'paleta'
# Model instance decoration
gem 'draper'

# For memory profiling
gem 'rack-mini-profiler', require: false

# CSS frameworks
gem 'normalize-rails'

gem 'autoprefixer-rails'

# Roles and Authorization
gem 'pundit', '~> 2.0', '>= 2.0.1'
gem 'rolify', '~> 5.2'

# Wizard
gem 'wicked'

# Recurrency
gem 'ice_cube'
gem 'recurring_select'

# Active Jobs
gem 'sidekiq', '~> 5.2', '>= 5.2.5'
gem 'sidekiq-scheduler', '~> 3.0'

# "Intelligent search made easy with Rails and Elasticsearch"
gem 'groupdate'
gem 'searchkick', '~> 4.1'

#  PDF generation
gem 'grover', '~> 0.8.1'

# Docx generation
gem 'caracal', '~> 1.4', '>= 1.4.1'

gem 'jwt'

# Dynamic Multiple Selects
gem 'select2-rails'

# For staging seeds
gem 'city-state'
gem 'factory_bot_rails', '~> 4.8', '>= 4.8.2', require: ENV['RAILS_ENV'] != 'production'

# Lets you define a single host name as the canonical host for your application.
# Requests for other host names will then be redirected to the canonical host.
gem 'rack-canonical-host', '~> 0.2.3'

gem 'devise'
gem 'devise-async'
gem 'devise_invitable', '~> 1.7.0'

gem 'aws-sdk-s3', '~> 1.9', require: false
gem 'azure-storage', require: false
gem 'kaminari'
gem 'mini_magick'

gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'

# Remote Error Logging
gem 'sentry-raven'

# IRR calculations
# TODO: Keep track of https://github.com/tubedude/xirr/pull/17
# In the mean time, use our fork:
gem 'xirr', github: 'icalialabs/xirr', ref: 'a5f1fd4'

# Caching
gem 'hiredis'

# XLS file generation
gem 'rubyzip', '>= 1.2.1'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'

# Dropzone for batch upload
gem 'dropzonejs-rails'
gem 'flipper-ui', '~> 0.17.1'

################################################################################
################################################################################
################################################################################

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
