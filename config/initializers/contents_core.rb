module ContentsCore
  @@editing = false

  @@config = {
    cc_blocks: {
      multi_text: {
        children_type: :text,
        name: 'Multi columns block',
        items: {
          column: :text
        }
      },
      text: {
        name: 'Text block',
        items: {
          title: :item_string,
          content: :item_text
        }
      },
    },
    items: {
      boolean: {},
      datetime: {},
      float: {},
      hash: {},
      file: {
        input: :file_image
      },
      integer: {},
      string: {},
      text: {
        input: :html
      },
    }
  }

  if defined? CarrierWave
    @@config[:cc_blocks].merge!({
      image: {
        name: 'Image block',
        items: {
          img: :item_file
        }
      },
      slide: {
        name: 'Slide block',
        items: {
          img: :item_file,
          title: :item_string
        }
      },
      slider: {
        children_type: :slide,
        name: 'Slider block',
        items: {
          slide: :slide
        }
      },
      text_with_image: {
        name: 'Text with image block',
        items: {
          img: :item_file,
          title: :item_string,
          content: :item_text
        }
      },
    })

    # ItemImage.class_eval do
    #   mount_uploader :data, ImageUploader
    # end
  end
end
