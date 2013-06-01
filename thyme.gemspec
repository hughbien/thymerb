Gem::Specification.new do |s|
  s.name        = 'thyme'
  s.version     = '0.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hugh Bien']
  s.email       = ['hugh@hughbien.com']
  s.homepage    = 'http://thymerb.com'
  s.summary     = "Timer for Pomodoro Technique"
  s.description = 'Extensible and configurable timer for Pomodoro Technique.'
 
  s.required_rubygems_version = '>= 1.3.6'
  s.add_dependency 'ruby-progressbar'
  s.add_development_dependency 'minitest'
 
  s.files        = Dir.glob('*.{rb,md}') + %w(thyme)
  s.bindir       = '.'
  s.executables  = ['thyme']
end
