# TODO: needs improvements
module ContentsCore
  class ItemObject < Item
    serialize :data_hash, JSON

    def data
      self.data_hash.deep_symbolize_keys
    end

    def data=( value )
      self.data_hash = value
    end

    def init
      self.data = {} unless self.data
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
      self.data_hash ? self.data_hash.inject( '' ) { |k, v| k + v[0] + ': ' + v[1] + "\n" } : {}
    end

    def self.permitted_attributes
      [ :data_hash ]
    end

    def self.type_name
      'object'
    end
  end
end
