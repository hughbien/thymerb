require_relative 'lib/thyme/version'
require 'rake/testtask'

task :default => :test

desc 'Run tests'
task :test do
  if file = ENV['TEST']
    File.exists?(file) ? require_relative(file) : puts("#{file} doesn't exist")
  else
    Dir.glob('./test/*_test.rb').each { |file| require(file) }
  end
end

desc 'Build gem'
task :build do
  `gem build thyme.gemspec`
end

desc 'Remove build artifacts'
task :clean do
  rm Dir.glob('*.gem')
end

desc 'Push gem to rubygems.org'
task :push => :build do
  `gem push thyme-#{Thyme::VERSION}.gem`
end

namespace :site do
  task :default => :build

  desc 'Build site'
  task :build do
    `cd site && stasis`
  end

  desc 'Push site to thymerb.com'
  task :push => [:clean, :build] do
    `rsync -avz --delete site/public/ thymerb.com:webapps/thymerb`
  end

  desc 'Remove built site artifacts'
  task :clean do
    rm_rf 'site/public'
  end
end
