defmodule CloudEventInspector.Validator do

  @keys [
    "cloudEventsVersion",
    "eventType",
    "source",
    "eventID",
    "eventTime",
    "contentType",
    "data"
  ]

  def is_invalid(log) do
    missing_keys(log) || bad_data(log)
  end

  # Validation functions
  def bad_data(log) do
    if(String.contains?(log["contentType"], "json") && Map.has_key?(log, "data")) do
      case Poison.decode(log["data"]) do
        {:error, _} -> true
        _ -> false
      end
    else
      false
    end
  end

  def missing_keys(log) do
    @keys
    |> Enum.any?(fn key -> !Map.has_key?(log, key) || String.trim(log[key]) == "" end)
  end

end
