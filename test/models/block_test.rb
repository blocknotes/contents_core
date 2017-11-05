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
      assert_equal block.block_type, 'text'
      assert_equal block.parent_id, @page.id
      assert_equal block.parent_type, Page.to_s
      assert_equal Block.count, 1
      assert_equal Item.count, 2
    end

    test 'should create a text block using create_block' do
      @page.create_block
      block = Block.last
      assert_equal block.block_type, 'text'
      assert_equal block.parent_id, @page.id
      assert_equal block.parent_type, Page.to_s
      assert_equal Block.count, 1
      assert_equal Item.count, 2
    end

    test 'should create a text block using create_block with name' do
      @page.create_block :text, { name: 'A block' }
      block = Block.last
      assert_equal block.name, 'A block'
      assert_equal block.config[:children], {title: :item_string, content: :item_text}
    end

    test 'should create a slider block without slides' do
      @page.create_block :slider
      assert_equal Block.where( block_type: 'slide' ).count, 0
    end

    test 'should create a slider block with 3 slides' do
      block = @page.create_block :slider, create_children: 3
      assert block.has_children?
      assert block.new_children, :slide
      assert_equal Block.where( block_type: 'slide', parent: block ).count, 3
      block = Block.where( block_type: 'slide', parent: block ).last
      assert block.is_sub_block?
      assert block.has_parent?
    end

    test 'should create a text block using create_block_in_parent' do
      ContentsCore::create_block_in_parent @page
      block = Block.last
      assert_equal block.block_type, 'text'
      assert_equal block.parent_id, @page.id
      assert_equal block.parent_type, Page.to_s
      assert_equal Block.count, 1
      assert_equal Item.count, 2
    end

    test 'should create a text block and initialize it with some values (hash)' do
      @page.create_block :slider, { create_children: 1, values: {slide: {title: 'A title...'}} }
      block = Block.last
      assert_equal block.get( 'slide.title' ), 'A title...'
    end

    test 'should create a text block and initialize it with some values (hash-list)' do
      @page.create_block :slider, { create_children: 1, values_list: { 'slide.title' => 'A title...' } }
      block = Block.last
      assert_equal block.get( 'slide.title' ), 'A title...'
    end

    test 'should not create a block without parent' do
      assert_not Block.new.save
    end

    # --- Destroy tests ---
    test 'should destroy items' do
      @page.create_block
      assert_equal Block.count, 1
      assert_equal Item.count, 2
      Block.last.destroy
      assert_equal Block.count, 0
      assert_equal Item.count, 0
    end

    test 'should destroy children blocks' do
      block = @page.create_block :slider, { create_children: 2 }
      assert_equal Block.count, 3
      assert_equal Item.count, 4
      block.destroy
      assert_equal Block.count, 0
      assert_equal Item.count, 0
    end

    # --- Access tests ---
    test 'should get an item of a block by name' do
      block = @page.create_block :slider, name: 'sld', create_children: 3
      assert_equal block.get( 'slide.title' ), ''
      block.set 'slide-2.title', 'A title...'
      block.save
      block = Block.last
      assert_equal block.get( 'slide-2.title' ), 'A title...'
    end

    # --- Other tests ---
    test 'should render to json' do
      block = @page.create_block :text, name: 'a-text', values: {title: 'A title', content: 'Some content'}
      json = block.as_json
      assert json['published']
      assert_equal json['block_type'], 'text'
      assert_equal json['name'], 'a-text'
      assert_equal json['items'][0]['name'], 'title'
      assert_equal json['items'][0]['data_string'], 'A title'
      assert_equal json['items'][1]['name'], 'content'
      assert_equal json['items'][1]['data_text'], 'Some content'
    end
  end
end
