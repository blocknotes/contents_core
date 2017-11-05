module ContentsCore
  class Block < ApplicationRecord
    # --- constants -----------------------------------------------------------
    # EMPTY_DATA = OpenStruct.new( { data: '' } )

    # --- misc ----------------------------------------------------------------
    attr_accessor :create_children
    serialize :conf, Hash

    # --- associations --------------------------------------------------------
    belongs_to :parent, polymorphic: true, touch: true
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
    validates_associated :cc_blocks
    validates_associated :items

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
      @create_children = 0
      self.conf = {} unless self.conf
      self.group = config[:group]
      self.block_type = parent.config[:new_children] if attributes[:block_type].nil? && self.parent_type == 'ContentsCore::Block'
    end

    def as_json( options = nil )
      super({ only: [:id, :block_type, :name, :group, :position, :published], include: [:cc_blocks, :items]}.merge(options || {}))
    end

    def attr_id
      "#{self.class.to_s.split('::').last}-#{self.id}"
    end

    def config
      !self.conf.blank? ? self.conf : ( ContentsCore.config[:blocks][block_type.to_sym] ? ContentsCore.config[:blocks][block_type.to_sym] : {} )
    end

    def create_item( item_type, options = {} )
      if ContentsCore.config[:items].keys.include? item_type
        attrs = { type: "ContentsCore::#{item_type.to_s.classify}" }  # TODO: check if model exists
        attrs[:name] = options[:name]  if options[:name]
        attrs[:data] = options[:value] if options[:value]
        item = self.items.new attrs
        item.save
        item
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
          'data-ec-container': self.new_children,
          'data-ec-ct': self.block_type,
          'data-ec-pub': self.published
        }
      ).map { |k, v| "#{k}=\"#{v}\"" }.join( ' ' ).html_safe : ''
    end

    # Returns an item value by name
    def get( name )
      item = get_item( name )
      item && item.is_a?( Item ) ? item.data : nil
    end

    # Returns an item by name
    def get_item( name )
      t = tree
      name.split( '.' ).each do |tok|
        return nil unless t[tok]
        t = t[tok]
      end
      t
    end

    def has_parent?
      parent.present?
    end

    def has_children?
      cc_blocks.exists?
    end

    def is_sub_block?
      self.parent.present? && self.parent.is_a?( Block )
    end

    def new_children
      config[:new_children]
    end

    def on_after_create
      # TODO: validates type before creation!
      Block.initialize_children( self, config[:children] ) if Block.types( false ).include?( self.block_type.to_sym )
    end

    # def on_after_initialize
    #   self.conf = {} unless self.conf
    # end

    def on_before_create
      names = parent.cc_blocks.map( &:name )
      if self.name.blank? || names.include?( self.name )  # Search a not used name
        n = self.name.blank? ? block_type : self.name
        i = 0
        while( ( i += 1 ) < 1000 )
          unless names.include? "#{n}-#{i}"
            self.name = "#{n}-#{i}"
            break
          end
        end
      end
    end

    def props
      pieces = {}

      Item.types.each do |type|
        pieces[type.to_s.pluralize.to_sym] = []
      end
      items.each do |item|  # TODO: improve me
        pieces[item.class.type_name.pluralize.to_sym] = [] unless pieces[item.class.type_name.pluralize.to_sym]
        pieces[item.class.type_name.pluralize.to_sym].push item
      end
      Item.types.each do |type|
        pieces[type] = pieces[type.pluralize.to_sym].any? ? pieces[type.pluralize.to_sym].first : nil  # EMPTY_DATA - empty Item per sti class?
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
      item = get_item( name )
      item && item.is_a?( Item ) ? item.data = value : nil
    end

    def tree
      # return @items_tree if @items_tree
      @items_tree = {}  # prepare a complete list of items
      self.items.each{ |item| @items_tree[item.name] = item }
      self.cc_blocks.each_with_index{ |block, i| @items_tree[block.name] = block.tree }  # @items_tree[i] = block.tree
      @items_tree
    end

    def validations
      config[:validations] || {}
    end

    def self.enum( include_children = true )
      ContentsCore.config[:blocks].map{|k, v| [I18n.t( 'contents_core.blocks.' + v[:name].to_s ), k.to_s] if !include_children || !v[:child_only]}.compact.sort_by{|b| b[0]}
    end

    def self.initialize_children( block, children, options = {} )
      children.each do |name, type|
        t = type.to_sym
        if Item.types.include? t
          c = 'ContentsCore::' + ActiveSupport::Inflector.camelize( t )
          begin
            model = c.constantize
          rescue Exception => e
            Rails.logger.error '[ERROR] ContentsCore - initialize_children: ' + e.message
            model = false
          end
          if model
            block.items.new( type: model.name, name: name )
          end
        elsif Block.types( false ).include? t
          block.create_children.times do
            block.cc_blocks.new( block_type: t, name: name )
            block.save
          end
        end
      end if children
      block.save
    end

    def self.items_keys( keys )
      keys.map do |k, v|
        v.is_a?( Hash ) ? items_keys( v ) : k
      end.flatten
    end

    def self.permitted_attributes
      [ :id, :name, :block_type, :position, :_destroy, items_attributes: [ :id ] + Item::permitted_attributes, cc_blocks_attributes: [ :id, :name, :block_type, items_attributes: [ :id ] + Item::permitted_attributes ] ]
    end

    def self.types( include_children = true )
      @@types ||= ContentsCore.config[:blocks].select{|k, v| !include_children || !v[:child_only]}.keys.map( &:to_sym )
    end
  end
end
