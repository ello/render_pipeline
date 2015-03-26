require 'html/pipeline'
require 'nokogiri'
require 'linguist'
require 'rinku'
require 'gemoji'
require 'github/markdown'
require 'truncato'
require 'rumoji'
require 'pygments'
require 'sanitize'

require 'render_pipeline/configuration'

module RenderPipeline
  # autoload :Adapters, 'ncmec_reporting/adapters/base'

  def self.sanitize(html, rules = {})
    Sanitize.clean(html, RenderPipeline.configuration.sanitize_rules.merge(rules))
  end

end
