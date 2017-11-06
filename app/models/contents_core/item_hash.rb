module ContentsCore
  class ItemHash < Item
    alias_attribute :data, :data_hash

    serialize :data_hash, Hash

    def init
      self.data = {} unless self.data
      self
    end

    def keys
      config[:keys] ? config[:keys] : self.data_hash.keys
    end

    def from_string( value )
      if value.is_a? String
        val = {}
        value.each_line do |line|
          m = line.match( /([^:]*):(.*)/ )
          val[m[1]] = m[2].strip if m && !m[1].blank?
        end
        self.data_hash = val.symbolize_keys
      end
    end

    def method_missing( method, *args, &block )
      matches = /data_([^=]+)([=]{0,1})/.match method.to_s
      if matches
        if matches[2].blank?
          return self.data[matches[1].to_sym]
        elsif matches[1]
          self.data[matches[1].to_sym] = args[0]
        end
      end
    end

    def respond_to?( method, include_private = false )
      method.to_s.starts_with?( 'data_' ) || super
    end

    def to_s
      self.data_hash ? self.data_hash.inject( '' ) { |k, v| "#{k}#{v[0]}: #{v[1]}\n" } : {}
    end

    def self.permitted_attributes
      [ :data_hash ]
    end

    def self.type_name
      'hash'
    end
  end
end
