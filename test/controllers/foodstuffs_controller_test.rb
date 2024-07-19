require "test_helper"

class FoodstuffsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @foodstuff = foodstuffs(:one)
  end

  test "should get index" do
    get foodstuffs_url
    assert_response :success
  end

  test "should get new" do
    get new_foodstuff_url
    assert_response :success
  end

  test "should create foodstuff" do
    assert_difference("Foodstuff.count") do
      post foodstuffs_url, params: { foodstuff: { description: @foodstuff.description, image: @foodstuff.image, link: @foodstuff.link, name: @foodstuff.name, price: @foodstuff.price } }
    end

    assert_redirected_to foodstuff_url(Foodstuff.last)
  end

  test "should show foodstuff" do
    get foodstuff_url(@foodstuff)
    assert_response :success
  end

  test "should get edit" do
    get edit_foodstuff_url(@foodstuff)
    assert_response :success
  end

  test "should update foodstuff" do
    patch foodstuff_url(@foodstuff), params: { foodstuff: { description: @foodstuff.description, image: @foodstuff.image, link: @foodstuff.link, name: @foodstuff.name, price: @foodstuff.price } }
    assert_redirected_to foodstuff_url(@foodstuff)
  end

  test "should destroy foodstuff" do
    assert_difference("Foodstuff.count", -1) do
      delete foodstuff_url(@foodstuff)
    end

    assert_redirected_to foodstuffs_url
  end
end
