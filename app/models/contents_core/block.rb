module ContentsCore
  class Block < ApplicationRecord
    # --- constants -----------------------------------------------------------
    EMPTY_DATA = OpenStruct.new( { data: '' } )

    # --- misc ----------------------------------------------------------------
    attr_accessor :create_children
    serialize :conf, JSON

    # --- associations --------------------------------------------------------
    belongs_to :parent, polymorphic: true
    has_many :cc_blocks, as: :parent, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Block'
    has_many :items, dependent: :destroy
    accepts_nested_attributes_for :cc_blocks, allow_destroy: true
    accepts_nested_attributes_for :items

    # --- callbacks -----------------------------------------------------------
    # after_initialize :on_after_initialize
    before_create :on_before_create
    after_create :on_after_create

    # --- scopes --------------------------------------------------------------
    default_scope { order( :position ) }
    scope :published, -> { where( published: true ) unless ContentsCore.editing }
    scope :with_nested, -> { includes( :items, cc_blocks: :items ) }

    # --- validations ---------------------------------------------------------
    validates_presence_of :block_type, :position

    # --- tmp -----------------------------------------------------------------
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

    # --- methods -------------------------------------------------------------
    def initialize( attributes = {}, &block )
      super( attributes, &block )
      @create_children = 1
      self.conf = {} unless self.conf
      self.group = config[:group]
      self.block_type = parent.config[:children_type] if attributes[:block_type].nil? && self.parent_type == 'ContentsCore::Block'
    end

    def as_json( options = nil )
      super({ only: [:id, :block_type, :name, :group, :position, :published], include: [:cc_blocks, :items]}.merge(options || {}))
    end

    def attr_id
      "#{self.class.to_s.split('::').last}-#{self.id}"
    end

    def children_type
      config[:children_type]
    end

    def config
      !self.conf.blank? ? self.conf.deep_symbolize_keys : ( ContentsCore.config[:cc_blocks][block_type.to_sym] ? ContentsCore.config[:cc_blocks][block_type.to_sym].deep_symbolize_keys : {} )
    end

    def create_item( item_type, item_name = nil, value = nil )
      if ContentsCore.config[:items].keys.include? item_type
        new_item = ContentsCore::Item.new( type: 'ContentsCore::' + item_type.to_s.classify )
        new_item.name = item_name if item_name
        new_item.data = value if value
        self.items << new_item
        new_item
      else
        raise "Invalid item type: #{item_type} - check defined items in config"
      end
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
      item = get_item( name )
      item.data if item
    end

    def get_item( name )
      unless @_items
        @_items = {}
        items.each { |item| @_items[item.name] = item }
      end
      @_items[name]
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
      Block::init_items( self, config[:items] ) if Block::block_types( false ).include?( self.block_type.to_sym )
    end

    # def on_after_initialize
    #   self.conf = {} unless self.conf
    # end

    def on_before_create
      if self.name.blank?
        names = parent.cc_blocks.map( &:name )
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

    def set( name, value )
      items.each do |item|
        if item.name == name
          item.data = value
          break
        end
      end
    end

    def validations
      config[:validations] || {}
    end

    def self.block_enum( include_children = true )
      ContentsCore.config[:cc_blocks].map{|k, v| [v[:name], k.to_s] if !include_children || !v[:child_only]}.compact.sort_by{|b| b[0]}
    end

    def self.block_types( include_children = true )
      ContentsCore.config[:cc_blocks].select{|k, v| !include_children || !v[:child_only]}.keys
    end

    def self.init_items( block, items, options = {} )
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
        elsif Block::block_types( false ).include? t.to_sym
          block.create_children.times do
            block.cc_blocks << Block.new( block_type: t, name: name )
          end
        end
      end if items
    end

    def self.permitted_attributes
      [ :id, :name, :block_type, :position, :_destroy, items_attributes: [ :id ] + Item::permitted_attributes, cc_blocks_attributes: [ :id, :name, :block_type, items_attributes: [ :id ] + Item::permitted_attributes ] ]
    end
  end
end
