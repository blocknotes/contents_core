require 'contents_core/blocks'
require 'contents_core/engine'

module ContentsCore
  def self.config( options = {} )
    @@config.merge! options
    @@config
  end

  def self.create_block_in_parent( parent, type = :text, params = {} )
    block = Block.new( block_type: type )
    block.name = params[:name] if params[:name]
    block.options = params[:options] if params[:options]
    block.validations = params[:validations] if params[:validations]
    parent.cc_blocks << block
    Block::init_items block, params[:schema] if params[:schema]
    block
  end

  def self.editing( editing = nil )
    @@editing = editing unless editing.nil?
    @@editing
  end
end
