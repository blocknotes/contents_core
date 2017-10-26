module ContentsCore
  @@editing = false

  @@config = {
    cc_blocks: {
      image: {
        name: 'Image block',
        items: {
          img: :item_file
        }
      },
      multi_text: {
        children_type: :text,
        name: 'Multi columns block',
        items: {
          column: :text
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
      text: {
        name: 'Text block',
        items: {
          title: :item_string,
          content: :item_text
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
    },
    items: {
      array: {},
      boolean: {},
      datetime: {},
      float: {},
      hash: {},
      file: {
        input: :file_image
      },
      integer: {},
      object: {},
      string: {},
      text: {
        input: :html
      },
    }
  }
end
