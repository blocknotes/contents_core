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
      assert_equal Item.count, 3
      assert_equal item.name, 'an-item'
    end

    test 'should create an array item' do
      @page.create_block.create_item :item_array, name: 'an-item', value: 5
      item = ItemArray.find_by name: 'an-item'
      assert_not item.is_multiple?
      assert_equal item.read_attribute( :data_integer ), 5
      assert_equal item.data, 5
      assert_equal item.to_s, '5'
      assert_equal item.data_type, :integer
      assert_equal item.class.type_name, 'array'
    end

    test 'should create an array item with values' do
      @page.create_block :custom, name: 'a-block', schema: { my_array: :item_array }, conf: { options: { my_array: { values: [ [ 'First', 1 ], [ 'Second', 2 ], [ 'Third', 3 ] ] } } }
      item = ContentsCore::ItemArray.first
      item.set 2
      assert_equal item.enum, [['First', 1], ['Second', 2], ['Third', 3]]
      assert_equal item.read_attribute( :data_integer ), 2
      assert_equal item.data, 2
    end

    # test 'should create an array item with values method' do  # NOTE: not possible - can't save a lambda in a record
    # end

    test 'should create a boolean item' do
      item = @page.create_block.create_item :item_boolean, name: 'an-item'
      item.set true
      item.save
      item = ItemBoolean.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_boolean ), true
      assert_equal item.data, true  # test alias
      assert_equal item.to_s, 'true'
      assert_equal item.class.type_name, 'boolean'
      assert_equal item.class.permitted_attributes, [:data_boolean]
    end

    test 'should create a datetime item' do
      dt = Time.zone.now.change hour: 12
      item = @page.create_block.create_item :item_datetime, name: 'an-item'
      item.set dt
      item.save
      item = ItemDatetime.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_datetime ).to_date, dt.to_date
      assert_equal item.data.to_date, dt.to_date  # test alias
      assert_equal item.class.type_name, 'datetime'
      assert_equal item.class.permitted_attributes, [:data_datetime]
      # TODO: check me
      # assert_equal data, dt
      # assert_equal item.data, dt  # test alias
    end

    test 'should create a file item' do
      item = @page.create_block.create_item :item_file, name: 'an-item'
      item.set 'a-filename'
      item.save
      item = ItemFile.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_file ), 'a-filename'
      assert_equal item.data, 'a-filename'  # test alias
      assert_equal item.class.type_name, 'file'
      assert_equal item.class.permitted_attributes, [:data_file]
    end

    test 'should create a float item' do
      item = @page.create_block.create_item :item_float, name: 'an-item'
      item.set 12.34
      item.save
      item = ItemFloat.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_float ), 12.34
      assert_equal item.data, 12.34  # test alias
      assert_equal item.to_s, '12.34'
      assert_equal item.class.type_name, 'float'
      assert_equal item.class.permitted_attributes, [:data_float]
    end

    test 'should create an hash item' do
      v = {a_key: 'A value', another_key: {a_sub_key: 'Another value'}}
      item = @page.create_block.create_item :item_hash, name: 'an-item'
      item.set v
      item.save
      item = ItemHash.find_by name: 'an-item'
      assert item.respond_to?( :data_a_key )
      assert_equal item.read_attribute( :data_hash ), v
      assert_equal item.data, v  # test alias
      assert_equal item.keys, [:a_key, :another_key]
      assert_equal item.data_a_key, 'A value'
      item.data_a_key = '***'
      assert_equal item.data_a_key, '***'
      assert_equal item.class.type_name, 'hash'
      assert_equal item.class.permitted_attributes, [:data_hash]
    end

    test 'should create an integer item' do
      @page.create_block.create_item :item_integer, name: 'an-item', value: 12
      item = ItemInteger.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_integer ), 12
      assert_equal item.data, 12  # test alias
      item.set 15
      item.save
      item = ItemInteger.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_integer ), 15
      assert_equal item.data, 15
      assert_equal item.to_s, '15'
      assert_equal item.class.type_name, 'integer'
      assert_equal item.class.permitted_attributes, [:data_integer]
    end

    test 'should create an object item' do
      v = {a_key: 'A value', another_key: {a_sub_key: 'Another value'}}
      @page.create_block.create_item :item_object, name: 'an-item', value: v
      item = ItemObject.find_by name: 'an-item'
      assert_equal item.data, v
      assert_equal item.class.type_name, 'object'
      assert_equal item.class.permitted_attributes, [:data_hash]
    end

    test 'should create a string item' do
      @page.create_block.create_item :item_string, name: 'an-item', value: 'A test string'
      item = ItemString.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_string ), 'A test string'
      assert_equal item.data, 'A test string'  # test alias
      assert_equal item.to_s, 'A test string'
      assert_equal item.class.type_name, 'string'
      assert_equal item.class.permitted_attributes, [:data_string]
    end

    test 'should create a text item' do
      @page.create_block.create_item :item_text, name: 'an-item', value: 'Some text'
      item = ItemText.find_by name: 'an-item'
      assert_equal item.read_attribute( :data_text ), 'Some text'
      assert_equal item.to_s, 'Some text'
      assert_equal item.class.type_name, 'text'
      assert_equal item.class.permitted_attributes, [:data_text]
    end

    test 'should not create an item without a block' do
      assert_not Item.new.save
    end

    # --- Other tests ---
    test 'should render to json' do
      item = @page.create_block.create_item :item_text, name: 'an-item', value: 'Some text'
      json = item.as_json
      json.delete 'id'
      assert_equal json, {'type' => 'ContentsCore::ItemText', 'name' => 'an-item', 'data' => 'Some text'}
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
