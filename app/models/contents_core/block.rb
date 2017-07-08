module ContentsCore
  class Block < ApplicationRecord
    EMPTY_DATA = OpenStruct.new( { data: '' } )

    # --- fields options ----------------------------------------------------- #
    serialize :options, JSON
    serialize :validations, JSON

    # --- relations ---------------------------------------------------------- #
    belongs_to :parent, polymorphic: true
    has_many :cc_blocks, as: :parent, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Block'
    has_many :items, dependent: :destroy
    accepts_nested_attributes_for :cc_blocks, allow_destroy: true
    accepts_nested_attributes_for :items

    # --- hooks -------------------------------------------------------------- #
    before_create :on_before_create
    after_create :on_after_create

    # --- scopes ------------------------------------------------------------- #
    default_scope { order( :position ) }
    scope :published, -> { where( published: true ) unless ContentsCore.editing }
    scope :with_nested, -> { includes( :items, cc_blocks: :items ) }

    # --- validations -------------------------------------------------------- #
    validates_presence_of :block_type, :position

    # --- misc --------------------------------------------------------------- #
    ## amoeba do
    ##   enable
    ##   # customize( lambda { |original_obj, new_obj|
    ##   #   original_obj.unit_pictures.each{|p| new_obj.unit_pictures.new(:data => File.open(p.data.file.path))}
    ##   # })
    ## end

    # after_validation :on_after_validation
    #
    # field :block_type, type: String, default: 'text'
    # field :name, type: String, default: ''
    # field :position, type: Integer, default: 0
    # field :published, type: Mongoid::Boolean, default: true
    # field :_init, type: Mongoid::Boolean, default: false
    #
    # embedded_in :parent, polymorphic: true
    #
    # embeds_many :cc_blocks, cascade_callbacks: true, order: :position.desc, class_name: 'ContentsCore::Block'
    # embeds_many :items, cascade_callbacks: true, class_name: 'ContentsCore::Item'
    #
    # accepts_nested_attributes_for :cc_blocks, allow_destroy: true
    # accepts_nested_attributes_for :items
    #
    # # scope :published, -> { where( published: true ) unless ApplicationController.edit_mode }

    def attr_id
      "#{self.class.to_s.split('::').last}-#{self.id}"
    end

    def children_type
      ContentsCore.config[:cc_blocks][block_type.to_sym][:children_type]
    end

    def editable
      ContentsCore.editing ? (
        is_sub_block? ?
        {
          'data-ec-sub-block': self.id,
          'data-ec-ct': self.block_type,
          'data-ec-position': self.position,
          'data-ec-pub': self.published
        } :
        {
          'data-ec-block': self.id,
          'data-ec-container': self.children_type,
          'data-ec-ct': self.block_type,
          'data-ec-pub': self.published
        }
      ).map { |k, v| "#{k}=\"#{v}\"" }.join( ' ' ).html_safe : ''
    end

    # Returns an item by name
    def get( name )
      unless @_items
        @_items = {}
        items.each { |item| @_items[item.name] = item }
      end
      @_items[name] ? @_items[name].data : nil
    end

    def has_parent?
      parent.present?
    end

    def has_children?
      cc_blocks.exists?
    end

    def is_sub_block?
      parent.present? && parent_type == 'ContentsCore::Block'
    end

    def on_after_create
      # TODO: validates type before creation!
      t = self.block_type.to_sym
      Block::init_items( self, ContentsCore.config[:cc_blocks][t][:items] ) if Block::block_types.include?( t )
    end

    def on_before_create
      if self.name.blank?
        names = parent.cc_blocks.map &:name
        i = 0
        while( ( i += 1 ) < 1000 )  # Search an empty group
          unless names.include? "#{block_type}-#{i}"
            self.name = "#{block_type}-#{i}"
            break
          end
        end
      end
    end

    def props
      pieces = {}

      Item::item_types.each do |type|
        pieces[type.pluralize.to_sym] = []
      end
      items.each do |item|  # TODO: improve me
        pieces[item.class.type_name.pluralize.to_sym].push item
      end
      Item::item_types.each do |type|
        pieces[type.to_sym] = pieces[type.pluralize.to_sym].any? ? pieces[type.pluralize.to_sym].first : nil  # EMPTY_DATA - empty Item per sti class?
      end

      # pieces = {
      #   images:   items.select { |item| item.type == ItemImage.to_s },
      #   integers: items.select { |item| item.type == ItemInteger.to_s },
      #   strings:  items.select { |item| item.type == ItemString.to_s },
      #   texts:    items.select { |item| item.type == ItemText.to_s },
      # }

      # pieces[:image]  = pieces[:images].any?  ? pieces[:images].first  : EMPTY_DATA
      # pieces[:integers]  = pieces[:integers].any?  ? pieces[:integers].first  : EMPTY_DATA
      # pieces[:string] = pieces[:strings].any? ? pieces[:strings].first : EMPTY_DATA
      # pieces[:text]   = pieces[:texts].any?   ? pieces[:texts].first   : EMPTY_DATA

      OpenStruct.new( pieces )
    end

    def self.block_types
      @@block_types ||= ContentsCore.config[:cc_blocks].keys
    end

    def self.init_items( block, items )
      items.each do |name, type|
        t = type.to_sym
        if type.to_s.start_with? 'item_'
          c = 'ContentsCore::' + ActiveSupport::Inflector.camelize( t )
          begin
            model = c.constantize
          rescue Exception => e
            Rails.logger.error '[ERROR] ContentsCore - init_items: ' + e.message
            model = false
          end
          block.items << model.new( name: name ).init if model
        elsif Block::block_types.include? t.to_sym
          block.cc_blocks << ( cmp = Block.new( block_type: t, name: name ) )
        end
      end if items
    end
  end
end
