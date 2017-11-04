module ContentsCore
  class ItemText < Item
    alias_attribute :data, :data_text

    def init
      self.data = ''  # self.name.gsub( /-/, ' ' ).humanize
      self
    end

    def update_data( value )
      self.data = ActionController::Base.helpers.sanitize( CGI.unescapeHTML( value ) )
      self.save
    end

    def self.permitted_attributes
      [ :data_text ]
    end

    def self.type_name
      'text'
    end
  end
end
