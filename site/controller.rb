require 'rubygems'
require 'homeostasis'

Homeostasis::Asset.concat 'all.css', %w(reset.css styles.css)
Homeostasis::Sitemap.config(url: 'http://thymerb.com')

ignore /\/_.*/
