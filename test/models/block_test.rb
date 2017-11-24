require 'pry'
require 'test_helper'

module ContentsCore
  class BlockTest < ActiveSupport::TestCase
    setup do
      Mongoid::Config.truncate!
      @page = Page.create
    end

    # --- Create tests ---
    test 'should create a text block using create_block' do
      @page.create_block
      block = Page.last.cc_blocks.last
      assert_equal 'text', block.block_type
      assert block.parent.is_a?( Page )
      assert_equal 2, block.items.count
    end

    test 'should create a text block using create_block with name' do
      @page.create_block :text, { name: 'A block' }
      block = Page.last.cc_blocks.last
      assert_equal 'A block', block.name
      assert_equal( {title: :item_string, content: :item_text}, block.config[:children] )
    end

    test 'should create a slider block without slides' do
      @page.create_block :slider
      assert_equal 0, Page.last.cc_blocks.where( block_type: 'slide' ).count
    end

    test 'should create a slider block with 3 slides' do
      block = @page.create_block :slider, create_children: 3
      assert block.has_children?
      assert_equal :slide, block.new_children
      assert_equal 3, block.cc_blocks.where( block_type: 'slide' ).count
      block = block.cc_blocks.where( block_type: 'slide' ).last
      assert block.is_sub_block?
      assert block.has_parent?
    end

    test 'should create a text block using create_block_in_parent' do
      ContentsCore::create_block_in_parent @page
      block = Page.last.cc_blocks.last
      assert_equal 'text', block.block_type
      assert block.parent.is_a?( Page )
      assert_equal 2, block.items.count
    end

    test 'should create a text block and initialize it with some values (hash)' do
      @page.create_block :slider, { create_children: 1, values: {slide: {title: 'A title...'}} }
      block = Page.last.cc_blocks.last
      assert_equal 'A title...', block.get( 'slide.title' )
    end

    test 'should create a text block and initialize it with some values (hash-list)' do
      @page.create_block :slider, { create_children: 1, values_list: { 'slide.title' => 'A title...' } }
      block = Page.last.cc_blocks.last
      assert_equal 'A title...', block.get( 'slide.title' )
    end

    test 'should not create a block without parent' do
      assert_not ContentsCore::create_block_in_parent( nil )
    end

    # --- Destroy tests ---
    test 'should destroy items' do
      @page.create_block
      block = Page.last.cc_blocks.last
      assert_equal 1, Page.last.cc_blocks.count
      assert_equal 2, block.items.count
      block.destroy
      assert_equal 0, Page.last.cc_blocks.count
    end

    test 'should destroy children blocks' do
      @page.create_block :slider, { create_children: 2 }
      block = Page.last.cc_blocks.last
      assert_equal 1, Page.last.cc_blocks.count
      assert_equal 2, block.cc_blocks.count
      assert_equal 4, block.cc_blocks.inject( 0 ) { |old, block| old += block.items.count }
      block.destroy
      assert_equal 0, Page.last.cc_blocks.count
    end

    # --- Access tests ---
    test 'should get an item of a block by name' do
      block = @page.create_block :slider, name: 'sld', create_children: 3
      assert_empty block.get( 'slide.title' )
      block.set 'slide-2.title', 'A title...'
      block.save
      block = Page.last.cc_blocks.last
      assert_equal 'A title...', block.get( 'slide-2.title' )
    end

    test 'should get the props of a block' do
      @page.create_block :text
      block = Page.last.cc_blocks.last
      assert block.props.strings[0].is_a?( ContentsCore::ItemString )
      assert block.props.texts[0].is_a?( ContentsCore::ItemText )
    end

    test 'should get the permitted attributes of a block' do
      assert [ :id, :name, :block_type, :position, :_destroy, items_attributes: [ :id ] + Item::permitted_attributes, cc_blocks_attributes: [ :id, :name, :block_type, items_attributes: [ :id ] + Item::permitted_attributes ] ], Block.permitted_attributes
    end

    # --- Other tests ---
    test 'should render to json' do
      block = @page.create_block :text, name: 'a-text', values: {title: 'A title', content: 'Some content'}
      json = block.as_json
      assert json['published']
      assert_equal 'text', json['block_type']
      assert_equal 'a-text', json['name']
      assert_equal 'title', json['items'][0]['name']
      assert_equal 'A title', json['items'][0]['data']
      assert_equal 'Some content', json['items'][1]['data']
    end

    test 'should return the block types' do
      @page.create_block :text
      block = Page.last.cc_blocks.last
      types = Block.enum.map{|type| type[1]}.sort
      assert_equal ['image', 'multi_text', 'slide', 'slider', 'text', 'text_with_image'], types
      assert_equal ['title', 'content'], Block.items_keys( block.tree )
    end
  end
end
