# require 'pry'
require 'test_helper'

module ContentsCore
  class BlockTest < ActiveSupport::TestCase
    setup do
      @page = Page.create title: 'Homepage', description: 'This is the homepage'
    end

    # --- Create tests ---
    test 'should create a text block with default options' do
      assert Block.new( parent: @page ).save
      block = Block.last
      assert_equal 'text', block.block_type
      assert_equal @page.id, block.parent_id
      assert_equal Page.to_s, block.parent_type
      assert_equal 1, Block.count
      assert_equal 2, Item.count
    end

    test 'should create a text block using create_block' do
      @page.create_block
      block = Block.last
      assert_equal 'text', block.block_type
      assert_equal @page.id, block.parent_id
      assert_equal Page.to_s, block.parent_type
      assert_equal 1, Block.count
      assert_equal 2, Item.count
    end

    test 'should create a text block using create_block with name' do
      @page.create_block :text, { name: 'A block' }
      block = Block.last
      assert_equal 'A block', block.name
      assert_equal( {title: :item_string, content: :item_text}, block.config[:children] )
    end

    test 'should create a slider block without slides' do
      @page.create_block :slider
      assert_equal 0, Block.where( block_type: 'slide' ).count
    end

    test 'should create a slider block with 3 slides' do
      block = @page.create_block :slider, create_children: 3
      assert block.has_children?
      assert_equal :slide, block.new_children
      assert_equal 3, Block.where( block_type: 'slide', parent: block ).count
      block = Block.where( block_type: 'slide', parent: block ).last
      assert block.is_sub_block?
      assert block.has_parent?
    end

    test 'should create a text block using create_block_in_parent' do
      ContentsCore::create_block_in_parent @page
      block = Block.last
      assert_equal 'text', block.block_type
      assert_equal @page.id, block.parent_id
      assert_equal Page.to_s, block.parent_type
      assert_equal 1, Block.count
      assert_equal 2, Item.count
    end

    test 'should create a text block and initialize it with some values (hash)' do
      @page.create_block :slider, { create_children: 1, values: {slide: {title: 'A title...'}} }
      block = Block.last
      assert_equal 'A title...', block.get( 'slide.title' )
    end

    test 'should create a text block and initialize it with some values (hash-list)' do
      @page.create_block :slider, { create_children: 1, values_list: { 'slide.title' => 'A title...' } }
      block = Block.last
      assert_equal 'A title...', block.get( 'slide.title' )
    end

    test 'should not create a block without parent' do
      assert_not Block.new.save
    end

    # --- Destroy tests ---
    test 'should destroy items' do
      @page.create_block
      assert_equal 1, Block.count
      assert_equal 2, Item.count
      Block.last.destroy
      assert_equal 0, Block.count
      assert_equal 0, Item.count
    end

    test 'should destroy children blocks' do
      block = @page.create_block :slider, { create_children: 2 }
      assert_equal 3, Block.count
      assert_equal 4, Item.count
      block.destroy
      assert_equal 0, Block.count
      assert_equal 0, Item.count
    end

    # --- Access tests ---
    test 'should get an item of a block by name' do
      block = @page.create_block :slider, name: 'sld', create_children: 3
      assert_empty block.get( 'slide.title' )
      block.set 'slide-2.title', 'A title...'
      block.save
      block = Block.last
      assert_equal 'A title...', block.get( 'slide-2.title' )
    end

    test 'should get the props of a block' do
      block = @page.create_block :text
      assert block.props.strings[0].is_a?( ContentsCore::ItemString )
      assert block.props.texts[0].is_a?( ContentsCore::ItemText )
    end

    # --- Other tests ---
    test 'should render to json' do
      block = @page.create_block :text, name: 'a-text', values: {title: 'A title', content: 'Some content'}
      json = block.as_json
      assert json['published']
      assert_equal 'text', json['block_type']
      assert_equal 'a-text', json['name']
      assert_equal 'title', json['items'][0]['name']
      assert_equal 'A title', json['items'][0]['data_string']
      assert_equal 'content', json['items'][1]['name']
      assert_equal 'Some content', json['items'][1]['data_text']
    end

    test 'should return the block types' do
      block = @page.create_block :text
      types = Block.enum.map{|type| type[1]}.sort
      assert_equal ['image', 'multi_text', 'slide', 'slider', 'text', 'text_with_image'], types
      assert_equal ['title', 'content'], Block.items_keys( block.tree )
    end
  end
end
