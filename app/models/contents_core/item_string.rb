module ContentsCore
  class ItemString < Item
    alias_attribute :data, :data_string

    validate :on_validate

    def init
      self.data = self.name.gsub( /-/, ' ' ).humanize
      self
    end

    def on_validate
      if self.block.validations[self.name]
        if self.block.validations[self.name] == 'required'
          self.errors.add( :base, "#{self.name} is required" ) if self.data_string.blank?
        end
      end
    end

    def update_data( value )
      self.data = ActionController::Base.helpers.sanitize( value, tags: [] )
      self.save
    end

    def self.type_name
      'string'
    end
  end
end
