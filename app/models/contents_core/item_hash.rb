module ContentsCore
  class ItemHash < Item
    alias_attribute :data, :data_hash

    serialize :data_hash, JSON

    def init
      self.data = {}
      self
    end

    def from_string( value )
      if value.is_a? String
        val = {}
        value.each_line do |line|
          m = line.match( /([^:]*):(.*)/ )
          val[m[1]] = m[2].strip if m && !m[1].blank?
        end
        self.data_hash = val
      end
    end

    def to_s
      self.data_hash.inject( '' ) { |k, v| k + v[0] + ': ' + v[1] + "\n" }
    end

    def self.permitted_attributes
      [ :data_hash ]
    end

    def self.type_name
      'hash'
    end
  end
end
