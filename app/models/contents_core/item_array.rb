module ContentsCore
  class ItemArray < Item
    serialize :data_hash, Array
    serialize :data_text, Array

    after_initialize do
      config[:data_type] ||= :integer
    end

    def data
      is_multiple? ? self.data_text : converted_data
    end

    def data=( value )
      if is_multiple?
        if config[:data_type]
          self.data_text = case config[:data_type].to_sym
            # when :boolean
            #   self.data_boolean = ( value == 1 ) || ( value == '1' ) || ( value == 'true' ) || ( value == 'yes' )
            when :float
              value.map( &:to_f )
            when :integer
              value.map( &:to_i )
            when :string, :text
              value.map( &:to_s )
            else
              value
            end
        else
          self.data_text = value
        end
      else
        convert_data( value )
      end
    end

    def enum( params = nil )
      config[:values] ? config[:values] : ( config[:values_method] ? config[:values_method].call( params ) : self.data_hash )
    end

    def init
      self.data_string = []
      self
    end

    def is_multiple?
      config[:multiple] ? true : false
    end

    def to_s
      self.data
    end

    def self.type_name
      'array'
    end
  end
end
