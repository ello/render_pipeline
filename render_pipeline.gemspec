$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'render_pipeline/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'render_pipeline'
  s.version     = RenderPipeline::VERSION
  s.authors     = ['jayzes', 'jejacks0n']
  s.email       = ['info@ello.co']
  s.homepage    = 'https://github.com/ello/ncmec_reporting'

  s.summary     = ''
  s.description = ''
  s.files       = Dir['{lib}/**/*'] + ['README.md']
  s.test_files  = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency 'nokogiri', '1.6.5' # Lock since 1.6.6 is buggy
  s.add_dependency 'html-pipeline' # must use modeset/html-pipeline
  s.add_dependency 'github-linguist'
  s.add_dependency 'sanitize'
  s.add_dependency 'rinku'
  s.add_dependency 'gemoji'
  s.add_dependency 'github-markdown'
  s.add_dependency 'truncato'
  s.add_dependency 'rumoji'
  s.add_dependency 'pygments.rb'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
end
