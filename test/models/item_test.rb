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
      block.create_item :item_integer, 'an-item'
      item = ItemInteger.find_by name: 'an-item'
      assert_equal Item.count, 3
      assert_equal item.name, 'an-item'
    end

    test 'should create an array item' do
      item = @page.create_block.create_item :item_array, 'an-item'
      item.set 5
      item.save
      item = ItemArray.find_by name: 'an-item'
      data = item.read_attribute( :data_integer )
      assert_equal data, 5
      assert_equal item.data, 5
    end

    test 'should create an array item with values' do
      @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { values: [ [ 'First', 1 ], [ 'Second', 2 ], [ 'Third', 3 ] ] } } }
      item = ContentsCore::ItemArray.first
      item.set 2
      assert_equal item.enum, [['First', 1], ['Second', 2], ['Third', 3]]
      data = item.read_attribute( :data_integer )
      assert_equal data, 2
      assert_equal item.data, 2
    end

    # test 'should create an array item with values method' do  # NOTE: not possible - can't save a lambda in a record
    # end

    test 'should create a boolean item' do
      item = @page.create_block.create_item :item_boolean, 'an-item'
      item.set true
      item.save
      item = ItemBoolean.find_by name: 'an-item'
      data = item.read_attribute( :data_boolean )
      assert_equal data, true
      assert_equal item.data, true  # test alias
    end

    test 'should create a datetime item' do
      dt = Time.zone.now.change hour: 12
      item = @page.create_block.create_item :item_datetime, 'an-item'
      item.set dt
      item.save
      item = ItemDatetime.find_by name: 'an-item'
      data = item.read_attribute( :data_datetime )
      assert_equal data.to_date, dt.to_date
      assert_equal item.data.to_date, dt.to_date  # test alias
      # TODO: check me
      # assert_equal data, dt
      # assert_equal item.data, dt  # test alias
    end

    test 'should create a file item' do
      item = @page.create_block.create_item :item_file, 'an-item'
      item.set 'a-filename'
      item.save
      item = ItemFile.find_by name: 'an-item'
      data = item.read_attribute( :data_file )
      assert_equal data, 'a-filename'
      assert_equal item.data, 'a-filename'  # test alias
    end

    test 'should create a float item' do
      item = @page.create_block.create_item :item_float, 'an-item'
      item.set 12.34
      item.save
      item = ItemFloat.find_by name: 'an-item'
      data = item.read_attribute( :data_float )
      assert_equal data, 12.34
      assert_equal item.data, 12.34  # test alias
    end

    test 'should create an hash item' do
      v = {a_key: 'A value', another_key: {a_sub_key: 'Another value'}}
      item = @page.create_block.create_item :item_hash, 'an-item'
      item.set v
      item.save
      item = ItemHash.find_by name: 'an-item'
      data = item.read_attribute( :data_hash )
      assert_equal data, v
      assert_equal item.data, v  # test alias
    end

    test 'should create an integer item' do
      item = @page.create_block.create_item :item_integer, 'an-item'
      item.set 12
      item.save
      item = ItemInteger.find_by name: 'an-item'
      data = item.read_attribute( :data_integer )
      assert_equal data, 12
      assert_equal item.data, 12  # test alias
    end

    test 'should create an object item' do
      v = {a_key: 'A value', another_key: {a_sub_key: 'Another value'}}
      item = @page.create_block.create_item :item_object, 'an-item'
      item.set v
      item.save
      item = ItemObject.find_by name: 'an-item'
      assert_equal item.data, v
    end

    test 'should create a string item' do
      item = @page.create_block.create_item :item_string, 'an-item'
      item.set 'A test string'
      item.save
      item = ItemString.find_by name: 'an-item'
      data = item.read_attribute( :data_string )
      assert_equal data, 'A test string'
      assert_equal item.data, 'A test string'  # test alias
    end

    test 'should create a text item' do
      item = @page.create_block.create_item :item_text, 'an-item'
      item.set 'Some text'
      item.save
      item = ItemText.find_by name: 'an-item'
      data = item.read_attribute( :data_text )
      assert_equal data, 'Some text'
    end

    test 'should not create an item without a block' do
      assert_not Item.new.save
    end
  end
end
