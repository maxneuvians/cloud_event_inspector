defmodule CloudEventInspectorWeb.Router do
  use CloudEventInspectorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :ingress do
    plug :accepts, ["json"]
  end

  scope "/", CloudEventInspectorWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/ingress", CloudEventInspectorWeb do
    pipe_through :ingress

    post "/", IngressController, :index
  end
end
