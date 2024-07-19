require "application_system_test_case"

class FoodstuffsTest < ApplicationSystemTestCase
  setup do
    @foodstuff = foodstuffs(:one)
  end

  test "visiting the index" do
    visit foodstuffs_url
    assert_selector "h1", text: "Foodstuffs"
  end

  test "should create foodstuff" do
    visit foodstuffs_url
    click_on "New foodstuff"

    fill_in "Description", with: @foodstuff.description
    fill_in "Image", with: @foodstuff.image
    fill_in "Link", with: @foodstuff.link
    fill_in "Name", with: @foodstuff.name
    fill_in "Price", with: @foodstuff.price
    click_on "Create Foodstuff"

    assert_text "Foodstuff was successfully created"
    click_on "Back"
  end

  test "should update Foodstuff" do
    visit foodstuff_url(@foodstuff)
    click_on "Edit this foodstuff", match: :first

    fill_in "Description", with: @foodstuff.description
    fill_in "Image", with: @foodstuff.image
    fill_in "Link", with: @foodstuff.link
    fill_in "Name", with: @foodstuff.name
    fill_in "Price", with: @foodstuff.price
    click_on "Update Foodstuff"

    assert_text "Foodstuff was successfully updated"
    click_on "Back"
  end

  test "should destroy Foodstuff" do
    visit foodstuff_url(@foodstuff)
    click_on "Destroy this foodstuff", match: :first

    assert_text "Foodstuff was successfully destroyed"
  end
end
