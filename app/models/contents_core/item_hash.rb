module ContentsCore
  class ItemHash < Item
    alias_attribute :data, :data_hash

    serialize :data_hash, JSON

    def init
      self.data = {}
      self
    end

    def self.type_name
      'hash'
    end
  end
end
