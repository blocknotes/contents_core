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

    test 'should create an array item' do
      item = @page.create_block.create_item 'ContentsCore::ItemArray', 'a-block'
      item.set 5
      item.save
      item = ItemArray.find_by name: 'a-block'
      data = item.read_attribute( :data_integer )
      assert_equal data, 5
      assert_equal item.data, 5
      if RUBY_VERSION.start_with? '2.4.'
        assert_equal data.class, Integer
      else
        assert_equal data.class, Fixnum
      end
    end

    # test 'should create an array item with values' do
    #   item = @page.create_block.create_item 'ContentsCore::ItemArray', 'a-block'
    #   binding.pry
    #   # item.set 5
    #   # item.save
    #   # item = ItemArray.find_by name: 'a-block'
    #   # data = item.read_attribute( :data_string )
    #   # assert_equal data, '5'
    #   # assert_equal item.data, '5'
    #   # assert_equal data.class, String
    # end

    test 'should create a boolean item' do
      item = @page.create_block.create_item 'ContentsCore::ItemBoolean', 'a-block'
      item.set true
      item.save
      item = ItemBoolean.find_by name: 'a-block'
      data = item.read_attribute( :data_boolean )
      assert_equal data, true
      assert_equal item.data, true  # test alias
      assert_equal data.class, TrueClass
    end

    test 'should create a datetime item' do
      dt = Time.zone.now.change hour: 12
      item = @page.create_block.create_item 'ContentsCore::ItemDatetime', 'a-block'
      item.set dt
      item.save
      item = ItemDatetime.find_by name: 'a-block'
      data = item.read_attribute( :data_datetime )
      assert_equal data.to_date, dt.to_date
      assert_equal item.data.to_date, dt.to_date  # test alias
      # TODO: check me
      # assert_equal data, dt
      # assert_equal item.data, dt  # test alias
      # assert_equal data.class, DateTime
      # assert_equal data.class, ActiveSupport::TimeWithZone
    end

    test 'should create a file item' do
      item = @page.create_block.create_item 'ContentsCore::ItemFile', 'a-block'
      item.set 'a-filename'
      item.save
      item = ItemFile.find_by name: 'a-block'
      data = item.read_attribute( :data_file )
      assert_equal data, 'a-filename'
      assert_equal item.data, 'a-filename'  # test alias
      assert_equal data.class, String
    end

    test 'should create a float item' do
      item = @page.create_block.create_item 'ContentsCore::ItemFloat', 'a-block'
      item.set 12.34
      item.save
      item = ItemFloat.find_by name: 'a-block'
      data = item.read_attribute( :data_float )
      assert_equal data, 12.34
      assert_equal item.data, 12.34  # test alias
      assert_equal data.class, Float
    end

    # test 'should create an hash item' do
    #   item = @page.create_block.create_item 'ContentsCore::ItemHash', 'a-block'
    #   # TODO
    # end

    test 'should create an integer item' do
      item = @page.create_block.create_item 'ContentsCore::ItemInteger', 'a-block'
      item.set 12
      item.save
      item = ItemInteger.find_by name: 'a-block'
      data = item.read_attribute( :data_integer )
      assert_equal data, 12
      assert_equal item.data, 12  # test alias
      if RUBY_VERSION.start_with? '2.4.'
        assert_equal data.class, Integer
      else
        assert_equal data.class, Fixnum
      end
    end

    # test 'should create an object item' do
    #   # TODO
    # end

    test 'should create a string item' do
      item = @page.create_block.create_item 'ContentsCore::ItemString', 'a-block'
      item.set 'A test string'
      item.save
      item = ItemString.find_by name: 'a-block'
      data = item.read_attribute( :data_string )
      assert_equal data, 'A test string'
      assert_equal item.data, 'A test string'  # test alias
      assert_equal data.class, String
    end

    test 'should create a text item' do
      item = @page.create_block.create_item 'ContentsCore::ItemText', 'a-block'
      item.set 'Some text'
      item.save
      item = ItemText.find_by name: 'a-block'
      data = item.read_attribute( :data_text )
      assert_equal data, 'Some text'
      assert_equal data.class, String
    end

    test 'should not create an item without a block' do
      assert_not Item.new.save
    end
  end
end
