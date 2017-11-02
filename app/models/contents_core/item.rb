module ContentsCore
  class Item < ApplicationRecord
    # field :data, type: String

    # embedded_in :cc_blocks

    belongs_to :block

    def as_json( options = nil )
      super( {only: [:id, :name, :type], methods: [:data]}.merge(options || {}) )
    end

    def attr_id
      "#{self.class_name}-#{self.id}"
    end

    def class_name
      self.class.to_s.split('::').last
    end

    def editable
      ContentsCore.editing ? " data-ec-item=\"#{self.id}\" data-ec-input=\"#{self.opt_input}\" data-ec-type=\"#{self.class_name}\"".html_safe : ''
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
      self.data
    end

    def update_data( value )
      self.data = value
      self.save
    end

    def self.item_types
      @@item_types ||= ContentsCore.config[:items].keys.map( &:to_s )
    end

    def self.permitted_attributes
      [ :data_boolean, :data_datetime, :data_file, :data_float, :data_hash, :data_integer, :data_string, :data_text ]
    end

    def config
      @config ||= self.block && self.block.config[:options] && self.block.config[:options][self.name.to_sym] ? self.block.config[:options][self.name.to_sym] : ( ContentsCore.config[:items][self.class::type_name.to_sym] ? ContentsCore.config[:items][self.class::type_name.to_sym] : {} )
    end

    def data_type
      @data_type ||= ( config[:data_type] || :string ).to_sym
    end

  protected

    def convert_data( value )
      # return ( data = config[:convert_method].call( data ) ) if config[:convert_method]
      if data_type
        case data_type
        when :boolean
          self.data_boolean = ( value == 1 ) || ( value == '1' ) || ( value == 'true' ) || ( value == 'yes' )
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

    def converted_data()
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
