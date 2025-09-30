# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rake/extensiontask'

task build: :compile # rubocop:disable Rake/Desc

GEMSPEC = Gem::Specification.load('numo-optimize.gemspec')

Rake::ExtensionTask.new('numo/optimize', GEMSPEC) do |ext|
  ext.lib_dir = 'lib/numo/optimize'
end

task default: %i[clobber compile test]
