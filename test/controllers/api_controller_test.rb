require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get open" do
    get :open
    assert_response :success
  end

  test "should get result" do
    get :result
    assert_response :success
  end

end
