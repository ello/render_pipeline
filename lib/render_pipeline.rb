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

module RenderPipeline
  module Filter
    autoload :Emoji, 'render_pipeline/filters/emoji'
    autoload :LinkAdjustments, 'render_pipeline/filters/link_adjustments'
    autoload :Markdown, 'render_pipeline/filters/markdown'
    autoload :Mentions, 'render_pipeline/filters/mentions'
    autoload :Rumoji, 'render_pipeline/filters/rumoji'
    autoload :SyntaxHighlighter, 'render_pipeline/filters/syntax_highlighter'
  end

  def self.sanitize(html, rules = {})
    Sanitize.clean(html, RenderPipeline.configuration.sanitize_rules.merge(rules))
  end

  def self.render(content, options = {})
    Renderer.new(content).render(options)
  end

end

require 'render_pipeline/configuration'
require 'render_pipeline/renderer'
