defmodule CloudEventInspectorWeb.PageController do
  use CloudEventInspectorWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
