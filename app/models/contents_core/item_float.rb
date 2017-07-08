module ContentsCore
  class ItemFloat < Item
    alias_attribute :data, :data_float

    def init
      self.data = 0
      self
    end

    def update_data( value )
      self.data = value.to_f
      self.save
    end

    def to_s
      self.data.to_s
    end

    def self.type_name
      'float'
    end
  end
end
