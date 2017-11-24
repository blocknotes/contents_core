require 'test_helper'

module ContentsCore
  class ViewItemsTest < ActionDispatch::IntegrationTest
    setup do
      Mongoid::Config.truncate!
      @page = Page.create
    end

    # test 'should print all items of a text block' do
    #   @page.create_block :text, values: {title: 'A title', content: 'Some content'}
    #   assert_equal 200, get( page_path( @page ) )  # @response.body
    #   assert_select '#blocks .item.title', 'A title'
    #   assert_select '#blocks .item.content', 'Some content'
    # end

    # test 'should print all items of a slider block' do
    #   @page.create_block :slider, name: 'a-slider', create_children: 2 # , values: {title: 'A title', content: 'Some content'}
    #   block = @page.get_block 'a-slider'
    #   block.set 'slide.title', 'A title'
    #   block.set 'slide.img', 'An image'
    #   block.set 'slide-1.title', 'Another title'
    #   block.set 'slide-1.img', 'Another image'
    #   assert_equal 200, get( page_path( @page ) )

    #   # <div class=\"block slide\"> <div class=\"item file img\"></div> <div class=\"item string title\"></div> </div> <div class=\"block slide-1\"><div class=\"block slide\"> <div class=\"item file img\"></div> <div class=\"item string title\"></div> </div> <div class=\"item file img\"></div> <div class=\"item string title\"></div> </div>

    #   #   # "<div class=\"item file img\">An image</div><div class=\"item string title\">A title</div><div class=\"item file img\">An image</div><div class=\"item string title\">A title</div><div class=\"item file img\">Another image</div><div class=\"item string title\">Another title</div>"

    #   # binding.pry

    #   # assert_select '#blocks .item.title', 'A title'
    #   # assert_select '#blocks .item.content', 'Some content'
    # end
  end
end
