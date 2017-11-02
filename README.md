# ContentsCore [![Gem Version](https://badge.fury.io/rb/contents_core.svg)](https://badge.fury.io/rb/contents_core) [![Build Status](https://travis-ci.org/blocknotes/contents_core.svg)](https://travis-ci.org/blocknotes/contents_core)

A Rails gem which offer a simple structure to manage contents in a flexible way.

Goals:

- attach the contents structure to a model transparently
- improve block views management
- add fields to blocks without migrations

### Install

- Add to the Gemfile:
`gem 'contents_core'`
- Copy migrations (Rails 5.x syntax, in Rails 4.x use `rake`):
`rails contents_core:install:migrations`
- Execute migrations
- Add the concern *Blocks* to your model (ex. *Page*): `include ContentsCore::Blocks`
- Add the blocks to a view (ex. *page show*): `= render partial: 'contents_core/blocks', locals: { container: @page }`

### Config

Edit the conf file: `config/initializers/contents_core.rb`

```ruby
module ContentsCore
  @@config = {
    cc_blocks: {
      text: {
        name: 'Solo testo',
        items: {
          title: :item_string,
          content: :item_text
        }
      },
      image: {
        name: 'Solo immagine',
        items: {
          img: :item_file
        }
      },
      slide: {
        name: 'Slide',
        child_only: true,
        items: {
          img: :item_file,
          link: :item_string,
          title: :item_string
        }
      },
      slider: {
        children_type: :slide,
        name: 'Slider',
        items: {
          slide: :slide
        }
      },
    },
    items: {
      item_boolean: {},
      item_datetime: {},
      item_float: {},
      item_hash: {},
      item_file: {
        input: :file_image
      },
      item_integer: {},
      item_string: {},
      item_text: {
        input: :html
      },
    }
  }
end
```

Create the new view blocks: `app/views/contents_core/_block_custom.html.slim`

```slim
- if block
  .title = block.get( 'title' )
  .text == block.get( 'content' )
  .image = image_tag block.get( 'image' ).url( :thumb )
```

#### Images

To add support for images add CarrierWave gem to your Gemfile and execute: `rails generate uploader Image` and update che config file *config/initializers/contents_core.rb* with:

```rb
module ContentsCore
  ItemFile.class_eval do
    mount_uploader :data_file, ImageUploader

    def init
      self.data_file = File.open( Rails.root.join( 'public', 'images', 'original', 'missing.jpg' ) )
      self
    end
  end
end
```

Another way is to override the *ItemFile* model (*app/models/contents_core/item_file.rb*):

```rb
module ContentsCore
  class ItemFile < Item
    mount_uploader :data_file, ImageUploader

    alias_attribute :data, :data_file

    def init
      self.data_file = File.open( Rails.root.join( 'public', 'images', 'original', 'missing.jpg' ) )
      self
    end

    def self.type_name
      'file'
    end
  end
end
```

#### Customizations

To create a "free form" block just use: `Page.first.create_block :intro, name: 'IntroBlock', schema: { intro: :item_string, subtitle: :item_string }`

Then create a *app/view/contents_core/_block_intro* view.

To list the blocks of a page: `Page.first.cc_blocks.pluck :name`

To add a new field to an existing block (ex. to first Page, on the first Block):

```rb
block = Page.first.get_block 'text-1'
block.create_item( :item_string, 'new-field' ).set( 'A test...' ).save
```

Then add to the block view: `block.get( 'new-field' )`

To set a field value: `block.set( 'new-field', 'Some value' )`

#### ActiveAdmin

If you use ActiveAdmin as admin interface you can find a sample model configuration: [page](extra/active_admin_page.rb) plus a js [page](extra/active_admin.js)

### Notes

- Blocks enum: `ContentsCore::Block.block_enum`
- Blocks types: `ContentsCore::Block.block_types`
- Default blocks [here](config/initializers/contents_core.rb)

#### Structure

- Including the Blocks concern to a model will add `has_many :cc_blocks` relationship (the list of blocks attached to a container) and some utility methods
- Block: UI component, a group of items (ex. a text with a title, a slider, a 3 column text widget, etc.); built with a list of sub blocks (for nested components) and a list of items
- Item: a single piece of information (ex. a string, a text, a boolean, an integer, a file, etc.) with a virtual method named *data*

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer
