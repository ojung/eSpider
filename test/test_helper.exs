ExUnit.start()

defmodule TestHelpers do
  def empty_response, do: respond(200)
  def empty_response(_, _), do: respond(200)

  def respond_body(_, _, body), do: respond(200, body, [])

  def redirect_response("http://new-location.com", _, _), do: empty_response
  def redirect_response("http://old-location.com", _, new_location) do
      respond(301, "", ["Location": new_location])
  end

  defp respond(status_code), do: respond(status_code, "", [])
  defp respond(status_code, body, headers) do
    %HTTPotion.Response{status_code: status_code, body: body, headers: headers}
  end
end
