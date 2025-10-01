# frozen_string_literal: true

require 'bundler/gem_tasks'

if ENV['BUNDLE_WITH'] == 'memcheck'
  require 'ruby_memcheck'
  require 'rake/testtask'
  test_config = lambda do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/test_*.rb']
  end
  Rake::TestTask.new(test: :compile, &test_config)
  namespace :test do
    RubyMemcheck::TestTask.new(valgrind: :compile, &test_config)
  end
else
  require 'minitest/test_task'
  Minitest::TestTask.create
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rake/extensiontask'

task build: :compile # rubocop:disable Rake/Desc

GEMSPEC = Gem::Specification.load('numo-optimize.gemspec')

Rake::ExtensionTask.new('numo/optimize', GEMSPEC) do |ext|
  ext.lib_dir = 'lib/numo/optimize'
end

task default: %i[clobber compile test]
