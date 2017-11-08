require 'test_helper'

module ContentsCore
  class ViewItemsTest < ActionDispatch::IntegrationTest
    setup do
      @page = Page.create title: 'Homepage', description: 'This is the homepage'
    end

    test 'should print all items of a text block' do
      @page.create_block :text, values: {title: 'A title', content: 'Some content'}
      get page_path( @page )
      assert_select '#blocks .item.title', 'A title'
      assert_select '#blocks .item.content', 'Some content'
    end

    # test 'should print all items of a slider block' do
    #   @page.create_block :slider, create_children: 2 # , values: {title: 'A title', content: 'Some content'}
    #   get page_path( @page )
    #   # assert_select '#blocks .item.title', 'A title'
    #   # assert_select '#blocks .item.content', 'Some content'
    # end
  end
end
