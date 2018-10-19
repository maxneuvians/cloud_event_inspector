defmodule CloudEventInspector.Spammer do
  use GenServer

  def init(args) do
    loop()
    {:ok, args}
  end

  def start(interval \\ 500) do
    GenServer.start_link(__MODULE__, interval)
  end

  def handle_info(:work, state) do
   loop(state)
   {:noreply, state}
  end

  def loop(interval \\ 500) do
    rand = Enum.random(0..1_000)
    if rand == 10 do
      send_invalid()
    else
      send_error()
    end
    Process.send_after(self(), :work, interval)
  end

  defp send_error() do
    payload = %{
      "cloudEventsVersion" => "0.1",
      "contentType" => "application/json",
      "data" => "{\"name\":\"FetchError\",\"message\":\"request to https://api.airtable.com/v0/appoFDwVvNMRSaO6o/questionClearLogic?view=Grid%20view failed, reason: getaddrinfo ENOTFOUND api.airtable.com api.airtable.com:443\",\"type\":\"system\",\"errno\":\"ENOTFOUND\",\"code\":\"ENOTFOUND\"}",
      "eventID" => Faker.UUID.v4(),
      "eventTime" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "eventType" => "com.github.cds-snc.vac-benefits-directory.error",
      "eventTypeVersion" => "1.0",
      "source" => "/utils/airtable_es2015.js"
    }
    HTTPoison.post "http://localhost:4000/ingress", Poison.encode!(payload), [{"Content-Type", "application/json"}]
  end

  defp send_invalid() do
    payload = %{
      "cloudEventsVersion" => "0.1",
      "contentType" => "application/json",
      "data" => "{\"name\":\"FetchError\",\"message\":\"request to https://api.airtable.com/v0/appoFDwVvNMRSaO6o/questionClearLogic?view=Grid%20view failed, reason: getaddrinfo ENOTFOUND api.airtable.com api.airtable.com:443\",\"type\":\"system\",\"errno\":\"ENOTFOUND\",\"code\":\"ENOTFOUND\"}",
      "eventID" => Faker.UUID.v4(),
      "eventType" => "com.github.cds-snc.vac-benefits-directory.error",
      "eventTypeVersion" => "1.0",
      "source" => "/utils/airtable_es2015.js"
    }
    HTTPoison.post "http://localhost:4000/ingress", Poison.encode!(payload), [{"Content-Type", "application/json"}]
  end

  defp send_info() do
    payload = %{
      "cloudEventsVersion" => "0.1",
      "contentType" => "text/plain",
      "data" => "Refreshing Cache ...",
      "eventID" => Faker.UUID.v4(),
      "eventTime" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "eventType" => "com.github.cds-snc.vac-benefits-directory.info",
      "eventTypeVersion" => "1.0",
      "source" => "/server.js"
    }
    HTTPoison.post "http://localhost:4000/ingress", Poison.encode!(payload), [{"Content-Type", "application/json"}]
  end


end
