# ContentsCore [![Gem Version](https://badge.fury.io/rb/contents_core.svg)](https://badge.fury.io/rb/contents_core)

A Rails gem which offer a simple structure to manage contents in a flexible way.

_NOTE_: this is an **ALPHA** version, major changes could happens - this is a refactoring of another gem of mine (editable_components)

Goals:

- attach the necessary data to a model transparently

- simplify the components development in views

- add blocks / items (= fields) without migrations

### Install

- Add to the Gemfile:
`gem 'contents_core'`

- Copy migrations (Rails 5.x syntax, in Rails 4.x use `rake`):
`rails contents_core:install:migrations`

- Migrate

- Add the concern *Blocks* to your model: `include ContentsCore::Blocks`

### Config

Edit the conf file: `config/initializers/contents_core.rb`

```ruby
conf = ContentsCore.config
# Adds a new custom block
conf[:cc_blocks][:custom] = {
  name: 'Custom block',
  items: {
    int1: :item_integer,
    int2: :item_integer,
    a_float: :item_float
  }
}
ContentsCore.config( { components: conf[:cc_blocks] } )
```

Create the new view blocks: `app/views/contents_core/_block_custom.html.erb`

```erb
<% if local_assigns[:block] %>
  <% block = local_assigns[:block] %>
  <div <%= block.editable %>>
    1st number: <span class="num1"<%= block.props.integers[0].editable %>><%= block.props.integers[0] %></span>
    - 2nd number: <span class="num2"<%= block.props.integers[1].editable %>><%= block.props.integers[1] %></span><br/>
    A float: <span <%= block.props.float.editable %>><%= block.props.float %></span><br/>
  </div>
<% end %>
```

##### Images

To add support for images add CarrierWave gem to your Gemfile and execute: `rails generate uploader File` and mount it in the model *app/models/contents_core/item_file.rb*:

```rb
module ContentsCore
  class ItemFile < Item
    mount_uploader :data_file, ImageUploader

    alias_attribute :data, :data_file

    def editable
      false
    end

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

##### Custom blocks

To create a "free form" block just use: `Page.first.create_block :intro, name: 'IntroBlock', schema: { intro: :item_string, subtitle: :item_string }`

### Dev Notes

##### Structure

- Including the Editable concern to a model will add `has_many :ec_blocks` relationship (the list of blocks attached to a container) and some utility methods

- Block: an editable UI component (ex. a text with a title, a slider, a 3 column text widgets, etc.); built with a list of sub blocks (for nested components) and a list of items

- Item: a single piece of information (ex. a string, a text, a boolean, an integer, a file, etc.)

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer
