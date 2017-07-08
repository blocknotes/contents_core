module ContentsCore
  class ItemDatetime < Item
    alias_attribute :data, :data_datetime

    def init
      self.data = Time.now
      self
    end

    def self.type_name
      'datetime'
    end
  end
end
