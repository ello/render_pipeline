require 'singleton'

module RenderPipeline
  class Configuration
    include Singleton

    class << self
      attr_accessor :sanitize_rules
    end

    self.sanitize_rules = {
      elements: %w(a b i strong em br),
      attributes: { 'a' => [ 'href' ] },
      protocols:  { 'a' => { 'href' => [ 'http', 'https', 'mailto' ] } },
      remove_contents: %w(script embed object style)
    }

  end

  @@configuration = Configuration

  def self.configuration
    @@configuration
  end

  def self.configuration=(config)
    @@configuration = config
  end

  def self.configure
    yield @@configuration
  end
end
