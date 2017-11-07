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
      block.create_item :item_integer, name: 'an-item'
      item = ItemInteger.find_by name: 'an-item'
      assert_equal 3, Item.count
      assert_equal 'an-item', item.name
    end

    test 'should create a base item' do
      block = @page.create_block
      item = block.items.new
      assert_not block.valid?
      item.type = 'ContentsCore::Item'
      assert block.save
      assert_equal [:data_boolean, :data_datetime, :data_file, :data_float, :data_hash, :data_integer, :data_string, :data_text], item.class.permitted_attributes
    end

    test 'should create an array item' do
      @page.create_block.create_item :item_array, name: 'an-item', value: 5
      item = ItemArray.find_by name: 'an-item'
      assert_not item.is_multiple?
      assert_equal 5, item.read_attribute( :data_integer )
      assert_equal 5, item.data
      assert_equal '5', item.to_s
      assert_equal :integer, item.data_type
      assert_equal 'array', item.class.type_name
    end

    test 'should create an array item (with many data types)' do
      block = @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { data_type: :float, values: [ [ 'Price 1', 45.5 ], [ 'Price 2', 39.9 ] ] } } }
      ( item = block.items.last ).update_data 38.2
      assert item.read_attribute( :data_float )
      block = @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { data_type: :string, values: [ '1st', '2nd', '3rd' ] } } }
      ( item = block.items.last ).update_data '1st'
      assert_equal '1st', item.read_attribute( :data_string )
      # block = @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { data_type: :text, values: [ 'One day i found a big book buried deep in the ground...' ] } } }
      # ( item = block.items.last ).update_data '...'
      # assert_equal '...', item.read_attribute( :data_text )
    end

    test 'should create an array item (multiple values)' do
      @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { multiple: true, values: [ 2, 4, 6, 8 ] } } }
      item = ContentsCore::ItemArray.last
      item.data = [4, 8]
      item.save
      item = ContentsCore::ItemArray.last
      assert item.is_multiple?
      assert_equal [4, 8], item.data
      # Data Type: float
      @page.create_block :custom, name: 'a-block-2', schema: { my_array: :item_array }, conf: { options: { my_array: { multiple: true, data_type: :float } } }
      item = ContentsCore::ItemArray.last
      item.data = [4.4, 8.8]
      assert_equal [4.4, 8.8], item.data
      # Data Type: string
      @page.create_block :custom, name: 'a-block-3', schema: { my_array: :item_array }, conf: { options: { my_array: { multiple: true, data_type: :string } } }
      item = ContentsCore::ItemArray.last
      item.data = ['', 'test']
      assert_equal ['', 'test'], item.data
    end

    test 'should create an array item with values' do
      @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { values: [ [ 'First', 1 ], [ 'Second', 2 ], [ 'Third', 3 ] ] } } }
      ContentsCore::ItemArray.last.update_data 2
      item = ContentsCore::ItemArray.last
      assert_equal [['First', 1], ['Second', 2], ['Third', 3]], item.enum
      assert_equal 2, item.read_attribute( :data_integer )
      assert_equal 2, item.data
    end

    # test 'should create an array item with values method' do  # NOTE: not possible - can't save a lambda in a record
    # end

    test 'should create a boolean item' do
      item = @page.create_block.create_item :item_boolean, name: 'an-item'
      assert_not item.read_attribute( :data_boolean )
      item.update_data true
      item = ItemBoolean.find_by name: 'an-item'
      assert item.read_attribute( :data_boolean )
      assert item.data  # test alias
      assert_equal 'true', item.to_s
      assert_equal 'boolean', item.class.type_name
      assert_equal [:data_boolean], item.class.permitted_attributes
      item.from_string 'false'
      assert_not item.read_attribute( :data_boolean )
      item.from_string 'yes'
      assert item.read_attribute( :data_boolean )
    end

    test 'should create a datetime item' do
      dt = Time.zone.now.change hour: 12
      item = @page.create_block.create_item :item_datetime, name: 'an-item'
      item.set dt
      item.save
      item = ItemDatetime.find_by name: 'an-item'
      assert_equal dt.to_date, item.read_attribute( :data_datetime ).to_date
      assert_equal dt.to_date, item.data.to_date  # test alias
      assert_equal 'datetime', item.class.type_name
      assert_equal [:data_datetime], item.class.permitted_attributes
      # TODO: check me
      # assert_equal data, dt
      # assert_equal item.data, dt  # test alias
    end

    test 'should create a file item' do
      item = @page.create_block.create_item :item_file, name: 'an-item'
      item.set 'a-filename'
      item.save
      item = ItemFile.find_by name: 'an-item'
      assert_equal 'a-filename', item.read_attribute( :data_file )
      assert_equal 'a-filename', item.data  # test alias
      assert_equal 'file', item.class.type_name
      assert_equal [:data_file], item.class.permitted_attributes
    end

    test 'should create a float item' do
      item = @page.create_block.create_item :item_float, name: 'an-item'
      item.update_data 12.34
      item = ItemFloat.find_by name: 'an-item'
      assert_equal 12.34, item.read_attribute( :data_float )
      assert_equal 12.34, item.data  # test alias
      assert_equal '12.34', item.to_s
      assert_equal 'float', item.class.type_name
      assert_equal [:data_float], item.class.permitted_attributes
    end

    test 'should create an hash item' do
      v = {a_key: 'A value', another_key: {a_sub_key: 'Another value'}}
      item = @page.create_block.create_item :item_hash, name: 'an-item'
      item.set v
      item.save
      item = ItemHash.find_by name: 'an-item'
      assert item.respond_to?( :data_a_key )
      assert_equal v, item.read_attribute( :data_hash )
      assert_equal v, item.data  # test alias
      assert_equal [:a_key, :another_key], item.keys
      assert_equal 'A value', item.data_a_key
      item.data_a_key = '***'
      assert_equal '***', item.data_a_key
      assert_equal 'hash', item.class.type_name
      assert_equal [:data_hash], item.class.permitted_attributes
      item.from_string "key_1: aaa\nkey_2: bbb"
      assert_equal "key_1: aaa\nkey_2: bbb\n", item.to_s
      assert_equal( { key_1: 'aaa', key_2: 'bbb' }, item.data )
    end

    test 'should create an integer item' do
      @page.create_block.create_item :item_integer, name: 'an-item', value: 12
      item = ItemInteger.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_integer ), 12
      assert_equal item.data, 12  # test alias
      item.update_data 15
      item = ItemInteger.find_by name: 'an-item'
      assert_equal 15, item.read_attribute( :data_integer )
      assert_equal 15, item.data
      assert_equal '15', item.to_s
      assert_equal 'integer', item.class.type_name
      assert_equal [:data_integer], item.class.permitted_attributes
    end

    test 'should create an object item' do
      v = {a_key: 'A value', another_key: {a_sub_key: 'Another value'}}
      @page.create_block.create_item :item_object, name: 'an-item', value: v
      item = ItemObject.find_by name: 'an-item'
      assert_equal v, item.data
      assert_equal "a_key: A value\nanother_key: {\"a_sub_key\"=>\"Another value\"}\n", item.to_s
      assert_equal 'object', item.class.type_name
      assert_equal [:data_hash], item.class.permitted_attributes
      item.from_string "key_1: aaa\nkey_2: bbb"
      assert_equal( { key_1: 'aaa', key_2: 'bbb' }, item.data )
    end

    test 'should create a string item' do
      item = @page.create_block.create_item :item_string, name: 'an-item', value: 'A test string'
      assert_equal 'A test string', item.read_attribute( :data_string )
      item.update_data 'Another string'
      item = ItemString.find_by name: 'an-item'
      assert_equal 'Another string', item.read_attribute( :data_string )
      assert_equal 'Another string', item.data  # test alias
      assert_equal 'Another string', item.to_s
      assert_equal 'string', item.class.type_name
      assert_equal [:data_string], item.class.permitted_attributes
    end

    test 'should create a text item' do
      item = @page.create_block.create_item :item_text, name: 'an-item', value: 'Some text'
      assert_equal 'Some text', item.read_attribute( :data_text )
      item.update_data 'Another text'
      item = ItemText.find_by name: 'an-item'
      assert_equal 'Another text', item.read_attribute( :data_text )
      assert_equal 'Another text', item.to_s
      assert_equal 'text', item.class.type_name
      assert_equal [:data_text], item.class.permitted_attributes
    end

    test 'should not create an item without a block' do
      assert_not Item.new.save
    end

    test 'should not create an item with an invalid type' do
      begin
        @page.create_block.create_item :item_any
      rescue Exception => e
        assert e.message.start_with?( 'Invalid item type' )
      end
    end

    # --- Other tests ---
    test 'should render to json' do
      item = @page.create_block.create_item :item_text, name: 'an-item', value: 'Some text'
      json = item.as_json
      json.delete 'id'
      assert_equal( {'type' => 'ContentsCore::ItemText', 'name' => 'an-item', 'data' => 'Some text'}, json )
    end

    test 'should return attr_id, class_name, data_type, permitted_attributes, type_name' do
      item = @page.create_block.create_item :item_text, name: 'an-item', value: 'Some text'
      assert_match /ItemText-[\d]+/, item.attr_id
      assert_equal 'ItemText', item.class_name
      assert_equal :string, item.data_type
      assert_equal 'text', item.class.type_name
      assert item.class.permitted_attributes.is_a?( Array )
    end
  end
end
