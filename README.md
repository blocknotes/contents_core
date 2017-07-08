# ContentsCore [![Gem Version](https://badge.fury.io/rb/contents_core.svg)](https://badge.fury.io/rb/contents_core)

A Rails gem which offer a simple structure to manage contents in a flexible way.

_NOTE_: this is an **ALPHA** version, major changes could happens - this is a refactoring of another gem of mine (editable_components)

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
conf = ContentsCore.config
# Adds a new custom block
conf[:cc_blocks][:custom] = {
  name: 'Custom block',
  items: {
    title: :item_string,
    content: :item_text,
    image: :item_file
  }
}
ContentsCore.config( { components: conf[:cc_blocks] } )
```

Create the new view blocks: `app/views/contents_core/_block_custom.html.erb`

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

To add a new field to an existing block (ex. to first Page, on the first Block):

```rb
Page.first.cc_blocks.first.items << ContentsCore::ItemString.new( name: 'new_field' )
Page.first.cc_blocks.first.items.last.update_attribute( :data, 'A test' )
```

### Notes

- Blocks types: `ContentsCore::Block.block_types`

- Default blocks (here)[https://github.com/blocknotes/contents_core/blob/master/config/initializers/contents_core.rb]

#### Structure

- Including the Blocks concern to a model will add `has_many :cc_blocks` relationship (the list of blocks attached to a container) and some utility methods

- Block: UI component, a group of items (ex. a text with a title, a slider, a 3 column text widgets, etc.); built with a list of sub blocks (for nested components) and a list of items

- Item: a single piece of information (ex. a string, a text, a boolean, an integer, a file, etc.)

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer
