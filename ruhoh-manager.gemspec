$LOAD_PATH.unshift 'lib'
require "ruhoh-manager/version"

Gem::Specification.new do |s|

  s.name        = "ruhoh-manager"
  s.version     = Ruhoh::Manager::VERSION
  s.authors     = ["Jiunn Haur Lim"]
  s.email       = ["codex.is.poetry@gmail.com"]
  s.homepage    = "https://github.com/jimjh/ruhoh-manager"
  s.summary     = "REST API for Ruhoh administration"
  s.description = "ruhoh-manager is a sinatra app that exposes a REST API for managing Ruhoh blogs"
  s.license     = "http://opensource.org/licenses/MIT"
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
  s.add_dependency 'sinatra', "~> 1.3.2"
  s.add_dependency 'ruhoh', "~> 1.0.0.alpha"

  # = MANIFEST =
  s.files = %w[
    Gemfile
    Rakefile
    lib/ruhoh-manager.rb
    lib/ruhoh-manager/version.rb
    ruhoh-manager.gemspec
  ]
  # = MANIFEST =

end
