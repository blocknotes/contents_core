module ContentsCore
  class ItemFile < Item
    # has_attached_file :data_string
    # validates_attachment_content_type :data_string, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

    # include Mongoid::Paperclip
    # has_mongoid_attached_file :data
    # validates_attachment_content_type :data, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

    # mount_uploader :data_file, ::FileUploader

    alias_attribute :data, :data_file

    def editable
      ContentsCore.editing ? { 'data-ec-item': self.id, 'data-ec-input': self.opt_input, 'data-ec-type': self.class_name, 'data-ec-block': self.block_id } : {}
    end

    def init
      # self.data_file = File.open( ContentsCore::Engine.root.join( 'lib', 'data', 'img1.jpg' ) )
      self
    end

    def self.type_name
      'file'
    end

    # before_validation :on_before_validation
    #
    # def on_before_validation
    #   self.data = File.open( 'rails/editable_components_test/public/img/img1.jpg' )
    #   # binding.pry
    # end

    # before_save :on_before_save
    # before_validation :on_before_validation
    # before_create :on_before_create
    # before_update :on_before_update
    # before_upsert :on_before_upsert
    #
    # def on_before_save; p '>>> before_save'; end
    # def on_before_validation; p '>>> before_validation'; end
    # def on_before_create; p '>>> before_create'; end
    # def on_before_update; p '>>> before_update'; end
    # def on_before_upsert; p '>>> before_upsert'; end
  end
end
