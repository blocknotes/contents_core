module ContentsCore
  class ItemFloat < Item
    alias_attribute :data, :data_float

    def init
      self.data = 0 unless self.data
      self
    end

    def update_data( value )
      self.data = value.to_f
      self.save
    end

    def self.permitted_attributes
      [ :data_float ]
    end

    def self.type_name
      'float'
    end
  end
end
