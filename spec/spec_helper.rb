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

# Prepares the temp directory
def setup
  FileUtils.mkdir TEMP_SITE_PATH
  FileUtils.cp_r File.join(TEST_SITE_PATH, '.'), TEMP_SITE_PATH
  # FIXME: I don't like this
  Ruhoh::Utils.stub(:parse_yaml_file).and_return({'theme' => 'twitter'})
  Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
  Ruhoh::Manager.setup :source => TEMP_SITE_PATH
end

# Removes the temp directory
def teardown
  FileUtils.remove_dir(TEMP_SITE_PATH, true) if Dir.exists? TEMP_SITE_PATH
  Ruhoh::Manager.reset
end

RSpec.configure do |config|
  config.before(:each) do
    setup
  end
  config.after(:each) do
    teardown
  end
end
