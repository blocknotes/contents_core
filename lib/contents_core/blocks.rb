module ContentsCore
  module Blocks
    extend ActiveSupport::Concern

    included do
      # embeds_many :cc_blocks, as: :parent, cascade_callbacks: true, order: :position.desc, class_name: 'ContentsCore::Block'
      has_many :cc_blocks, as: :parent, dependent: :destroy, foreign_key: 'parent_id', class_name: Block.to_s
      accepts_nested_attributes_for :cc_blocks, allow_destroy: true

      def create_block( type = :text, params = {} )
        ContentsCore::create_block_in_parent( self, type, params )
      end

      def current_blocks( version = 0 )
        return @current_blocks if @current_blocks
        version = 0 unless ContentsCore.editing  # no admin = only current version
        @current_blocks = cc_blocks.where( version: version.to_i ).with_nested.published
      end

      def get_block( name, version = 0 )
        current_blocks( version ).each do |block|
          return block if block.name == name
        end
        nil
      end
    end
  end
end
