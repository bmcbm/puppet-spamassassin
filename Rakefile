require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

task :default => [:spec, :lint, :syntax, :validate]
task :test => :default

desc 'Run puppet in noop mode and check for syntax errors.'
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
  Dir['*.yaml','data/**/*.yaml'].each do |yamlfile|
    sh "ruby -e \"require 'yaml'; YAML.load_file('#{yamlfile}')\""
  end

end

desc 'Validate that README.md documents all parameters for each class'
task :validate_readme do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "ext/check_readme.sh #{manifest} README.md"
  end
end

