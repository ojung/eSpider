defmodule ESpider.HTTP.HandlerTest do
  import ESpider.HTTP.Handler
  import Mock

  use ExUnit.Case, async: false

  test "fetch url" do
    with_mock HTTPotion, [get: &TestHelpers.empty_response/2] do
      fetch("http://example.com", 0)
      assert(called(HTTPotion.get("http://example.com", :_)))
    end
  end

  test "follow redirect" do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, "http://new-location.com")
    ] do
      fetch("http://old-location.com", 0)
      assert(called(HTTPotion.get("http://new-location.com", :_)))
    end
  end

  test "give up after 3 redirects" do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, "http://old-location.com")
    ] do
      url ="http://old-location.com"
      err = {:error, [message: "Possible redirect loop detected for: " <> url]}
      assert(fetch(url, 0) == err)
    end
  end
end
