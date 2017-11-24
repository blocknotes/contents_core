module ContentsCore
  class ItemBoolean < Item
    field :data_boolean, type: Boolean

    alias_attribute :data, :data_boolean

    def init
      self.data = false unless self.data
      self
    end

    def from_string( value )
      self.data = ( value == 1 ) || ( value == '1' ) || ( value == 'true' ) || ( value == 'yes' )
    end

    def update_data( value )
      self.data = value
      self.save
    end

    def to_s
      self.data_boolean ? 'true' : 'false'
    end

    def self.permitted_attributes
      [ :data_boolean ]
    end

    def self.type_name
      'boolean'
    end
  end
end
