# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
#  config.action_controller.session_store = :active_record_store
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
 config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_travis_0wnZ_j3w3r_s0ulz',
    :secret      => '0a627ed2386cb923be95cdd4611a9dad2ba86b7c7bdd4692a83d92ea7062817f2dec0d86e47162539c589ac5d9e397e7aa849ad71e1edbb2a18dcee3e5a1cc1c'
  }
  config.gem 'haml', :version => '>=2.0.8'
  config.gem 'flexmock'
  config.gem 'bones'
  config.gem 'lockfile'
  config.gem 'logging', :version => '>=0.9.7'
  config.gem 'ziya', :version => '>=2.0.7'
  config.gem 'mislav-will_paginate', :version => '>=2.3.8', :source => 'http://gems.github.com', :lib => 'will_paginate'
  config.gem 'calendar_date_select', :version => '>=1.15'

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  #config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = 'Central Time (US & Canada)'
#  config.time_zone = 'Central Time (US & Canada)'


end
CalendarDateSelect.format = :hyphen_ampm
TRAVIS_DOMAIN='travis.local'
TRAVIS_ADMIN_EMAIL='travis@example.com'
