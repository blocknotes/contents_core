module ContentsCore
  class Item < ApplicationRecord
    # field :data, type: String

    # embedded_in :cc_blocks

    belongs_to :block

    def as_json
      super( {only: [:id, :name, :type], methods: [:data]} )
    end

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

    def set( value )
      self.data = value
      self
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

    def self.permitted_attributes
      [ :data_boolean, :data_datetime, :data_file, :data_float, :data_hash, :data_integer, :data_string, :data_text ]
    end

  protected

    def config
      @config ||= self.block.config[:options] && self.block.config[:options][self.name.to_sym] ? self.block.config[:options][self.name.to_sym] : ( ContentsCore.config[:items][self.class::type_name.to_sym] ? ContentsCore.config[:items][self.class::type_name.to_sym] : {} )
    end
  end
end
