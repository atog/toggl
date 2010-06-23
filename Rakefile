require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "toggl"
    gem.summary = %Q{Toggl api ruby gem}
    gem.description = %Q{Toggl provides a simple REST-style JSON API over standard HTTP - http://www.toggl.com}
    gem.email = "koen@atog.be"
    gem.homepage = "http://github.com/atog/toggl"
    gem.authors = ["Koen Van der Auwera"]
    gem.files = FileList['lib/**/*.rb']
    gem.test_files = []
    gem.add_dependency('crack', '>= 0.1.7')
    gem.add_dependency('httparty', '>= 0.6.0')
    gem.add_dependency('chronic_duration', '>= 0.9.0')
    gem.add_dependency('hirb', '>= 0.3.1')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "toggl #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
