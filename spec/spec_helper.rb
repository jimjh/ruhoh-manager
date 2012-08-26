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
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ruhoh-manager'
require 'rspec'
require 'rack/test'

# configure test environment
ENV['RACK_ENV'] = 'test'

TEST_SITE_PATH = File.join(File.dirname(__FILE__), 'test-site')
TEMP_SITE_PATH = File.expand_path '__tmp'
OAUTH_CLIENT_ID = '000000000000000000000001'
OAUTH_CLIENT_SECRET = 'y'

# Prepares the temp directory.
def setup_blog
  FileUtils.mkdir TEMP_SITE_PATH
  FileUtils.cp_r File.join(TEST_SITE_PATH, '.'), TEMP_SITE_PATH
  # FIXME: I don't like this; change it when we can handle multiple ruhohs
  Ruhoh::Utils.stub(:parse_yaml_file).and_return('theme' => 'twitter')
  Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
  Ruhoh::Manager.setup_ruhoh source: TEMP_SITE_PATH, env: 'test'
end

# Prepares a mock database.
def setup_db
  Ruhoh::Manager.setup env: 'test'
  require 'ruhoh-manager/api'
  Rack::OAuth2::Server.options[:collection_prefix] = 'oauth2'
  Rack::OAuth2::Server.register \
    display_name: 'Test Client',
    link: 'http://test/',
    scope: %w{read write},
    redirect_uri: 'http://test/callback',
    id: BSON::ObjectId.from_string(OAUTH_CLIENT_ID),
    secret: OAUTH_CLIENT_SECRET
end

# Removes the temp directory.
def teardown_blog
  FileUtils.remove_dir(TEMP_SITE_PATH, true) if Dir.exists? TEMP_SITE_PATH
  Ruhoh::Manager.reset_ruhoh
end

# Resets the database.
def teardown_db
  db =  Ruhoh::Manager.database
  db.connection.drop_database db.name
end

RSpec.configure do |config|
  config.before(:all) { setup_db }
  config.after(:all) { teardown_db }
  config.before(:each) { setup_blog }
  config.after(:each) { teardown_blog }
end
