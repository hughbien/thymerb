require 'rubygems'
require 'homeostasis'
require 'compass'

Stasis::Options.set_template_option 'scss', Compass.sass_engine_options
Homeostasis::Asset.concat 'all.css', %w(styles.css)
Homeostasis::Sitemap.config(url: 'http://thymerb.com')

ignore /\/_.*/
ignore /\/\.saas-cache\/.*/
ignore /.*\.scssc/
