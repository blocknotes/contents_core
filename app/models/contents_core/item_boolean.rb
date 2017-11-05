module ContentsCore
  class ItemBoolean < Item
    alias_attribute :data, :data_boolean

    def init
      self.data = false unless self.data
      self
    end

    def update_data( value )
      self.data = ( value == 'true' ) ? 1 : 0
      self.save
    end

    def to_s
      self.data > 0 ? 'true' : 'false'
    end

    def self.permitted_attributes
      [ :data_boolean ]
    end

    def self.type_name
      'boolean'
    end
  end
end
