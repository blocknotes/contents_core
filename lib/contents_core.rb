require 'contents_core/blocks'
require 'contents_core/engine'

module ContentsCore
  def self.config( options = {} )
    @@config.merge! options
    @@config
  end

  def self.editing( editing = nil )
    @@editing = editing unless editing.nil?
    @@editing
  end
end
