module ContentsCore
  class ItemInteger < Item
    alias_attribute :data, :data_integer

    def init
      self.data = 0
      self
    end

    def update_data( value )
      self.data = value.to_i
      self.save
    end

    def to_s
      self.data.to_s
    end

    def self.type_name
      'integer'
    end
  end
end
