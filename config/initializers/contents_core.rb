module ContentsCore
  @@editing = false

  @@config = {
    blocks: {
      image: {
        name: 'Image block',
        children: {
          img: :item_file
        }
      },
      multi_text: {
        name: 'Multi columns block',
        new_children: :text,
        children: {
          column: :text
        },
      },
      slide: {
        name: 'Slide block',
        children: {
          img: :item_file,
          title: :item_string
        }
      },
      slider: {
        name: 'Slider block',
        new_children: :slide,
        children: {
          slide: :slide
        }
      },
      text: {
        name: 'Text block',
        children: {
          title: :item_string,
          content: :item_text
        }
      },
      text_with_image: {
        name: 'Text with image block',
        children: {
          img: :item_file,
          title: :item_string,
          content: :item_text
        }
      },
    },
    items: {
      item_array: {},
      item_boolean: {},
      item_datetime: {},
      item_float: {},
      item_hash: {},
      item_file: {
        input: :file_image
      },
      item_integer: {},
      item_object: {},
      item_string: {},
      item_text: {
        input: :html
      },
    }
  }
end
