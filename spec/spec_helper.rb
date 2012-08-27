require 'rubygems'
require 'bundler/setup'

# bundle install
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

# load gem
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ruhoh-manager'
require 'rspec'
require 'rack/test'

# load shared contexts
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'oauth_context'
require 'blog_context'

# configure test environment
ENV['RACK_ENV'] = 'test'

# Prepares a mock database.
def setup_db
  Ruhoh::Manager.setup env: 'test'
  require 'ruhoh-manager/api'
end

# Resets the database.
def teardown_db
  db = Ruhoh::Manager.database
  db.connection.drop_database db.name
end

RSpec.configure do |config|
  config.before(:all) { setup_db }
  config.after(:all) { teardown_db }
end
