# require 'pry'
require 'test_helper'

module ContentsCore
  class BlockTest < ActiveSupport::TestCase
    setup do
      @page = Page.create title: 'Homepage', description: 'This is the homepage'
    end

    # test 'the truth' do
    #   assert true
    # end

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
      assert_equal block.config[:items], {:title=>:item_string, :content=>:item_text}
    end

    test 'should create a slider block without slides' do
      @page.create_block :slider, { create_children: 0 }
      assert_equal Block.where( block_type: 'slide' ).count, 0
    end

    test 'should create a slider block with 3 slides' do
      block = @page.create_block :slider, { create_children: 3 }
      assert block.has_children?
      assert block.children_type, :slide
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

    test 'should not create a block without parent' do
      assert_not Block.new.save
    end

    # --- Create tests ---
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
  end
end
