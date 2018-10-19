defmodule CloudEventInspectorWeb.IngressController do
  use CloudEventInspectorWeb, :controller

  def index(conn, %{"cloudEventsVersion" => "0.1"} = log) do
    CloudEventInspector.Filter.filter(log)
    text(conn, "OK")
  end

end
