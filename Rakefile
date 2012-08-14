$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[lib]))
require 'rubygems'
require 'rake'
require 'bundler'
require 'ruhoh-manager/version'
require 'rspec/core/rake_task'

name = Dir['*.gemspec'].first.split('.').first
gemspec_file = "#{name}.gemspec"
gem_file = "#{name}-#{Ruhoh::Manager::VERSION}.gem"

task :release => :build do
  sh "git commit --allow-empty -m 'Release #{Ruhoh::Manager::VERSION}'"
  sh "git tag v#{Ruhoh::Manager::VERSION}"
  sh "git push origin master --tags"
  sh "git push origin v#{Ruhoh::Manager::VERSION}"
  sh "gem push pkg/#{name}-#{Ruhoh::Manager::VERSION}.gem"
end

task :build => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

task :gemspec do
  # read spec file and split out manifest section
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg|coverage)/ }.
    map { |file| "    #{file}" }.
    join("\n")

  # piece file back together and write
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }
  puts "Updated #{gemspec_file}"
end

## Tests

RSpec::Core::RakeTask.new('spec')

desc "Run tests"
task :default => :spec
