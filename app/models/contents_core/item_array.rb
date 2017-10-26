module ContentsCore
  class ItemArray < Item
    alias_attribute :data, :data_string

    serialize :data_hash, Array

    def enum
      config[:values] ? config[:values] : self.data_hash
    end

    def init
      self.data = ''
      self
    end

    def to_s
      self.data
    end

    def self.permitted_attributes
      [:data_string, :data_hash]
    end

    def self.type_name
      'array'
    end
  end
end
