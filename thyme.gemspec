Gem::Specification.new do |s|
  s.name        = 'thyme'
  s.version     = '0.0.16'
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['BSD']
  s.authors     = ['Hugh Bien']
  s.email       = ['hugh@hughbien.com']
  s.homepage    = 'http://hughbien.com/thyme/'
  s.summary     = "Timer for Pomodoro Technique"
  s.description = 'Extensible and configurable timer for Pomodoro Technique.'
 
  s.required_rubygems_version = '>= 1.3.6'
  s.add_dependency 'ruby-progressbar', '~> 1.0'
 
  s.files        = Dir.glob('*.md') + Dir.glob('bin/*') + Dir.glob('lib/**/*.rb')
  s.bindir       = 'bin'
  s.executables  = ['thyme']
end
