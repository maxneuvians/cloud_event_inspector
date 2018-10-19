defmodule CloudEventInspector.Filter do
  use GenServer

  def init(args) do
    loop(0)
    {:ok, args}
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{
      filters: [
        {:contains, "com.github.cds-snc.vac-benefits-directory.info"}
      ], total: 0
    }, name: __MODULE__)
  end

  def dispatch_invalid(log) do
    CloudEventInspectorWeb.Endpoint.broadcast("room:lobby", "invalid", log)
  end

  def dispatch_match(log) do
    CloudEventInspectorWeb.Endpoint.broadcast("room:lobby", "match", log)
  end

  def increase_total() do
    GenServer.cast(__MODULE__, :inc_total)
  end

  def filter(log) do
    increase_total()
    if CloudEventInspector.Validator.is_invalid(log) do
      dispatch_invalid(log)
    else
      filters = filters()
      type = log["eventType"]
      content =
        case log["contentType"] do
          "text/plain" -> %{"content" => log["data"]}
          other ->
            if String.contains?(other, "json") do
              Poison.decode!(log["data"])
            else
              %{}
            end
        end
      # Run filters
      Task.start(fn -> if(run_filters(type, filters), do: dispatch_match(log)) end)
      Task.start(fn -> if(run_filters(content, filters), do: dispatch_match(log)) end)
    end
  end

  def filters() do
    GenServer.call(__MODULE__, :filters)
  end

  def run_filters(content, filters) when is_map(content) do
    Map.values(content)
    |> Enum.any?(&(run_filters(&1, filters)))
  end

  def run_filters(content, filters) when is_binary(content) do
    filters
    |> Enum.any?(fn {type, value} ->
      case type do
        :contains -> String.contains?(content, value)
        _ -> false
      end
    end)
  end

  def total() do
    GenServer.call(__MODULE__, :total)
  end

  def update(new_state) do
    GenServer.cast(__MODULE__, {:filters, new_state})
  end

  # Callbacks
  def handle_call(:filters, _from, state) do
    {:reply, state[:filters], state}
  end

  def handle_call(:total, _from, state) do
    {:reply, state[:total], state}
  end

  def handle_cast({:filters, new_state}, state) do
    {:noreply, Map.put(state, :filters, new_state)}
  end

  def handle_cast(:inc_total, state ) do
    {:noreply, Map.put(state, :total, state[:total] + 1)}
  end

  def handle_info(:work, state) do
   loop(state[:total])
   {:noreply, state}
  end

  def loop(total) do
    CloudEventInspectorWeb.Endpoint.broadcast("room:lobby", "total", %{total: total})
    Process.send_after(self(), :work, 1_000)
  end
end
