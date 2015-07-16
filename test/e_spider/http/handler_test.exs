defmodule ESpider.HTTP.HandlerTest do
  import ESpider.HTTP.Handler
  import Mock

  use ExUnit.Case, async: false

  @old_location "http://old-location.com"
  @new_location "http://new-location.com"
  @some_url "http://example.com"


  test "fetch url" do
    with_mock HTTPotion, [get: &TestHelpers.empty_response/2] do
      fetch(@some_url, 0)
      assert(called(HTTPotion.get(@some_url, :_)))
    end
  end

  test "follow redirect" do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, @new_location)
    ] do
      fetch(@old_location, 0)
      assert(called(HTTPotion.get(@new_location, :_)))
    end
  end

  test "give up after 3 redirects" do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, @old_location)
    ] do
      err = {:error,
        [message: "Possible redirect loop detected for: " <> @old_location]}
      assert(fetch(@old_location, 0) == err)
    end
  end
end
