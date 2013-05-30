require File.expand_path('thyme', File.dirname(__FILE__))

task :default => :test

task :test do
  ruby '*_test.rb'
end

task :build do
  `gem build thyme.gemspec`
end

task :clean do
  rm Dir.glob('*.gem')
end

task :push => :build do
  `gem push thyme-#{Thyme::VERSION}.gem`
end
