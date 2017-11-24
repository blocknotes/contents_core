module ContentsCore
  class Item < ApplicationRecord
    # field :type, type: String
    field :name, type: String

    # field :block_id, type: Integer
    # field :data_boolean, type: Boolean
    # field :data_datetime, type: DateTime
    # field :data_file, type: String
    # field :data_float, type: Float
    # field :data_hash, type: Hash
    # field :data_integer, type: Integer
    # field :data_string, type: String
    # field :data_text, type: String
    # t.timestamps null: false
    embedded_in :block
    # embedded_in :cc_blocks

    alias_attribute :type, :_type

    # --- associations --------------------------------------------------------
    # belongs_to :block, touch: true

    # --- callbacks -----------------------------------------------------------
    after_initialize :on_after_initialize
    before_create :on_before_create

    # --- misc ----------------------------------------------------------------
    # field :data, type: String

    # --- validations ---------------------------------------------------------
    validate :validate_item
    validates :block, presence: true, allow_blank: false
    # validates :type, presence: true, allow_blank: false

    # --- methods -------------------------------------------------------------
    def on_after_initialize
      self.data = config[:default] if config[:default] && !self.data
      self.init
    end

    def as_json( options = nil )
      super( {only: [:id, :name], methods: [:data, :type]}.merge( options || {} ) )
    end

    def attr_id
      "#{self.class_name}-#{self.id}"
    end

    def class_name
      self.class.to_s.split( '::' ).last
    end

    def config
      # @config ||=
      ( ContentsCore.config[:items] && ContentsCore.config[:items][self.class_name.underscore.to_sym] ? ContentsCore.config[:items][self.class_name.underscore.to_sym] : {} ).merge( self.block && self.block.config[:options] && self.name && self.block.config[:options][self.name.to_sym] ? self.block.config[:options][self.name.to_sym] : {} ).deep_symbolize_keys
    end

    def data_type
      # @data_type ||=
      ( config[:data_type] || :string ).to_sym
    end

    def editable
      ContentsCore.editing ? " data-ec-item=\"#{self.id}\" data-ec-input=\"#{self.opt_input}\" data-ec-type=\"#{self.class_name}\"".html_safe : ''
    end

    def init  # placeholder method (for override)
    end

    def on_before_create
      # root_block = self.block
      # root_block = root_block.parent while root_block.parent.is_a? Block
      # names = Block.items_keys root_block.tree
      names = ( self.block.items - [self] ).pluck :name
      if self.name.blank? || names.include?( self.name )  # Search a not used name
        n = self.name.blank? ? self.class.type_name : self.name
        i = 0
        while( ( i += 1 ) < 1000 )
          unless names.include? "#{n}-#{i}"
            self.name = "#{n}-#{i}"
            break
          end
        end
      end
    end

    def opt_input
      if self.block.config[self.name] && self.block.config[self.name]['input']
        self.block.config[self.name]['input'].to_s
      elsif config[:input]
        config[:input].to_s
      else
        ''
      end
    end

    def process_data( args = nil )
      config[:process_data].call( self.data, args ) if config[:process_data]
    end

    def set( value )
      self.data = value
      self
    end

    def to_s
      self.data.to_s
    end

    def update_data( value )
      self.data = value
      self.save
    end

    def validate_item
      config[:validate].call( self ) if config[:validate]
    end

    def self.permitted_attributes
      [:data_boolean, :data_datetime, :data_file, :data_float, :data_hash, :data_integer, :data_string, :data_text]
    end

    def self.type_name
      ''
    end

    def self.types
      @@types ||= ContentsCore.config[:items].keys.map( &:to_sym )
    end

  protected

    def convert_data( value )
      # return ( data = config[:convert_method].call( data ) ) if config[:convert_method]
      if data_type
        case data_type
        when :boolean
          self.data_boolean = value.is_a? TrueClass
        when :float
          self.data_float = value.to_f
        when :integer
          self.data_integer = value.to_i
        when :text
          self.data_text = value.to_s
        else  # :string or other
          self.data_string = value.to_s
        end
      else  # :string or other
        self.data_string = value.to_s
      end
    end

    def converted_data
      if data_type
        case data_type
        when :boolean
          self.data_boolean
        when :float
          self.data_float
        when :integer
          self.data_integer
        when :text
          self.data_text
        else  # :string or other
          self.data_string
        end
      else  # :string or other
        self.data_string
      end
    end
  end
end
