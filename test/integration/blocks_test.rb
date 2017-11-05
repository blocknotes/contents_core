require 'test_helper'

module ContentsCore
  class BlocksTest < ActionDispatch::IntegrationTest
    setup do
      @page = Page.create title: 'Homepage', description: 'This is the homepage'
    end

    test 'should return the current blocks' do
      @page.create_block :text
      @page.create_block :slider
      block = @page.create_block :text
      # TODO: check order
      assert_equal 3, @page.current_blocks.count
      block.published = false
      block.save
      assert_equal 2, @page.current_blocks.count
      assert_equal 3, @page.cc_blocks.count
    end

    test 'should return a block by name' do
      @page.create_block :text
      @page.create_block :slider, name: 'a-slider'
      @page.create_block :text
      block = @page.get_block 'a-slider'
      assert_equal 'slider', block.block_type
      assert_equal @page, block.parent
    end

    # test 'should return a block cache key (protected)' do
    #   block = @page.create_block :text
    #   key = block.send :cache_key
    #   assert_match /contents_core\/blocks\/[\d]+-[\d]+/, key
    # end
  end
end
