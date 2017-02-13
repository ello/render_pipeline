$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'render_pipeline/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'render_pipeline'
  s.version     = RenderPipeline::VERSION
  s.authors     = ['jayzes', 'jejacks0n']
  s.email       = ['engineering@ello.co']
  s.homepage    = 'https://github.com/ello/render_pipeline'

  s.summary     = ''
  s.description = ''
  s.files       = Dir['{lib}/**/*'] + ['README.md']
  s.test_files  = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency 'activesupport'
  s.add_dependency 'nokogiri', '>= 1.6.7.2'
  s.add_dependency 'html-pipeline', '~> 2.0'
  s.add_dependency 'rinku'
  s.add_dependency 'gemoji'
  s.add_dependency 'github-markdown'
  s.add_dependency 'truncato'
  s.add_dependency 'rumoji'
  s.add_dependency 'pygments.rb', '~> 0.6.3'
  s.add_dependency 'fastimage'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
