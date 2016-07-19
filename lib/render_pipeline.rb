require 'render_pipeline/version'
require 'html/pipeline'
require 'nokogiri'
require 'rinku'
require 'gemoji'
require 'github/markdown'
require 'truncato'
require 'rumoji'
require 'pygments'
require 'fastimage'

module RenderPipeline
  module Filter
    autoload :Code, 'render_pipeline/filters/code'
    autoload :Emoji, 'render_pipeline/filters/emoji'
    autoload :ImageAdjustments, 'render_pipeline/filters/image_adjustments'
    autoload :Hashtag, 'render_pipeline/filters/hashtag'
    autoload :LinkAdjustments, 'render_pipeline/filters/link_adjustments'
    autoload :Markdown, 'render_pipeline/filters/markdown'
    autoload :Mentions, 'render_pipeline/filters/mentions'
    autoload :Rumoji, 'render_pipeline/filters/rumoji'
    autoload :SyntaxHighlighter, 'render_pipeline/filters/syntax_highlighter'
  end

  def self.render(content, options = {})
    Renderer.new(content).render(options)
  end
end

require 'render_pipeline/configuration'
require 'render_pipeline/renderer'
