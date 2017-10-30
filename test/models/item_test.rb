require 'pry'
require 'test_helper'

module ContentsCore
  class ItemTest < ActiveSupport::TestCase
    setup do
      @page = Page.create title: 'Homepage', description: 'This is the homepage'
    end

    # --- Create tests ---
    test 'should create an item' do
      block = @page.create_block
      block.create_item 'ContentsCore::ItemInteger', 'a-block'
      item = ItemInteger.find_by name: 'a-block'
      assert_equal Item.count, 3
      assert_equal item.name, 'a-block'
    end

    test 'should create a text item' do
      item = @page.create_block.create_item 'ContentsCore::ItemText', 'a-block'
      item.set 'Some text'
      item.save
      item = ItemText.find_by name: 'a-block'
      data = item.read_attribute( :data_text )
      assert_equal data, 'Some text'
      assert data.is_a?( String )
    end

    test 'should create an integer item' do
      item = @page.create_block.create_item 'ContentsCore::ItemInteger', 'a-block'
      item.set 12
      item.save
      item = ItemInteger.find_by name: 'a-block'
      data = item.read_attribute( :data_integer )
      assert_equal data, 12
      assert data.is_a?( Fixnum )
    end

    test 'should not create an item without a block' do
      assert_not Item.new.save
    end
  end
end
