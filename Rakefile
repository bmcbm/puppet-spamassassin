require 'rake'

require 'rspec/core/rake_task'

require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

## I'm sure this isn't what I should do here, but I don't see what I
## should be doing with this module
PuppetLint.configuration.send('disable_autoloader_layout')

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

task :default => [:spec, :lint, :syntax]

task :test => :default
