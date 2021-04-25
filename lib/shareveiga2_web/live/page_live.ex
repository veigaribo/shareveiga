defmodule Shareveiga2Web.PageLive do
  use Shareveiga2Web, :live_view

  @global_topic "global"

  @impl true
  def mount(_params, _session, socket) do
    Shareveiga2Web.Endpoint.subscribe(@global_topic)

    text = Shareveiga2Core.Storage.get()

    {:ok, assign(socket, text: text)}
  end

  @impl true
  def handle_event("save", %{"t" => text}, socket) do
    Shareveiga2Core.Storage.set(text)

    Shareveiga2Web.Endpoint.broadcast_from(self(), @global_topic, "text_update", text)

    {:noreply, assign(socket, text: text)}
  end

  @impl true
  def handle_info(%{event: "text_update", payload: text}, socket) do
    {:noreply, assign(socket, text: text)}
  end
end
