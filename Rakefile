require File.expand_path('thyme', File.join(File.dirname(__FILE__), 'lib'))

task :default => :spec

desc 'Run specs'
task :spec do
  ruby 'spec/*_spec.rb'
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
    rm_r 'site/public'
  end
end
