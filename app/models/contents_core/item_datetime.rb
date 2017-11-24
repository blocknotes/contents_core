module ContentsCore
  class ItemDatetime < Item
    field :data_datetime, type: DateTime

    alias_attribute :data, :data_datetime

    def init
      self.data = Time.now unless self.data
      self
    end

    def self.permitted_attributes
      [ :data_datetime ]
    end

    def self.type_name
      'datetime'
    end
  end
end
