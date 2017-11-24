module ContentsCore
  class ItemInteger < Item
    field :data_integer, type: Integer

    alias_attribute :data, :data_integer

    def init
      self.data = 0 unless self.data
      self
    end

    def update_data( value )
      self.data = value.to_i
      self.save
    end

    def self.permitted_attributes
      [ :data_integer ]
    end

    def self.type_name
      'integer'
    end
  end
end
