module ContentsCore
  class Item < ApplicationRecord
    # field :data, type: String

    # embedded_in :cc_blocks

    belongs_to :block

    def attr_id
      "#{self.class_name}-#{self.id}"
    end

    def class_name
      self.class.to_s.split('::').last
    end

    def editable
      ContentsCore.editing ? " data-ec-item=\"#{self.id}\" data-ec-input=\"#{self.opt_input}\" data-ec-type=\"#{self.class_name}\"".html_safe : ''
    end

    def opt_input
      if self.block.options[self.name] && self.block.options[self.name]['input']
        self.block.options[self.name]['input'].to_s
      elsif config[:input]
        config[:input].to_s
      else
        ''
      end
    end

    def to_s
      self.data
    end

    def update_data( value )
      self.data = value
      self.save
    end

    def self.item_types
      @@item_types ||= ContentsCore.config[:items].keys.map &:to_s
    end

  protected

    def config
      @config ||= ContentsCore.config[:items][self.class::type_name.to_sym] ? ContentsCore.config[:items][self.class::type_name.to_sym] : {}
    end
  end
end
