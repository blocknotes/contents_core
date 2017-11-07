# ContentsCore [![Gem Version](https://badge.fury.io/rb/contents_core.svg)](https://badge.fury.io/rb/contents_core) [![Build Status](https://travis-ci.org/blocknotes/contents_core.svg)](https://travis-ci.org/blocknotes/contents_core) [![Dependency Status](https://gemnasium.com/badges/github.com/blocknotes/contents_core.svg)](https://gemnasium.com/github.com/blocknotes/contents_core) [![Test Coverage](https://api.codeclimate.com/v1/badges/59196100a1ebb599b088/test_coverage)](https://codeclimate.com/github/blocknotes/contents_core/test_coverage)

A Rails gem which offer a structure to manage contents in a flexible way: blocks with recursive nested blocks + items as "leaves"

_Disclaimer: this component is in ALPHA, major changes could happen_

Goals:
- attach the contents structure to a model transparently
- add fields to blocks without migrations
- offer helpers to render blocks in views
- cache-ready

## Install

- Add to the Gemfile:
`gem 'contents_core'`
- Copy migrations (Rails 5.x syntax, in Rails 4.x use `rake`):
`rails contents_core:install:migrations`
- Execute migrations
- Add the concern *Blocks* to your model (ex. *Page*): `include ContentsCore::Blocks`
- Optionally add the blocks to a view (ex. *page show*): `= render partial: 'contents_core/blocks', locals: { container: @page }`

## Usage

### Working with blocks/items

- Basic operations (example parent model: *Page*):
```ruby
page = Page.first
page.create_block :slider, name: 'a-slider', create_children: 3  # Create a silder with 3 slides
page.current_blocks.map{ |block| block.name }  # current_blocks -> all published ordered blocks and query cached
block = page.get_block 'a-slider'
block.tree  # list all items of a block
block.get 'slide-2.title'  # get value of 'title' field of sub block with name 'slide-2' (name automatically generated at creation)
block.set 'slide-2.title'  # set field value
block.save
```

- Other operations:
```ruby
block = ContentsCore::Block.last
ContentsCore.create_block_in_parent block, :text  # create a sub block in a block
block.create_item :item_string, name: 'a-field'
```

## Config

Edit the conf file: `config/initializers/contents_core.rb`

```ruby
module ContentsCore
  @@config = {
    blocks: {
      text: {
        name: :text_only,       # used as reference / for translations
        children: {             # children: sub blocks & items
          title: :item_string,
          content: :item_text
        }
      },
      image: {
        name: :image_only,
        children: {
          img: :item_file
        }
      },
      slide: {
        name: :a_slide,
        child_only: true,       # used only as child of another block (slider)
        children: {
          img: :item_file,
          link: :item_string,
          title: :item_string
        }
      },
      slider: {
        name: :a_slider,
        new_children: :slide,   # block type used when creating a new child with default params
        children: {
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

### Images

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

## Customizations

To create a "free form" block just use: `Page.first.create_block :intro, name: 'IntroBlock', schema: { intro: :item_string, subtitle: :item_string }`

Then create a *app/view/contents_core/_block_intro* view.

To list the blocks of a page manually (but *current_blocks* method is the preferred way): `Page.first.cc_blocks.pluck :name`

To add a new field to an existing block (ex. to first Page, on the first Block):

```rb
block = Page.first.get_block 'text-1'
block.create_item( :item_string, name: 'new-field' ).set( 'A test...' ).save
```

Then add to the block view: `block.get( 'new-field' )`

To set a field value: `block.set( 'new-field', 'Some value' )`

### ActiveAdmin

If you use ActiveAdmin as admin interface you can find a sample model configuration: [page](extra/active_admin_page.rb) plus a js [page](extra/active_admin.js)

## Notes

- Blocks enum: `ContentsCore::Block.enum`
- Blocks types: `ContentsCore::Block.types`
- Default blocks [here](config/initializers/contents_core.rb)

### Structure

- Including the Blocks concern to a model will add `has_many :cc_blocks` relationship (the list of blocks attached to a container) and some utility methods
- Block: UI component, a group of items (ex. a text with a title, a slider, a 3 column text widget, etc.); built with a list of sub blocks (for nested components) and a list of items
- Item: a single piece of information (ex. a string, a text, a boolean, an integer, a file, etc.) with a virtual method named *data*

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer
