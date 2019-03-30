defmodule LiveChatWeb.ChatLive.Index do
  use Phoenix.LiveView

  alias LiveChat.Chat
  alias Chat.Message

  def mount(_session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    LiveChatWeb.ChatView.render("index.html", assigns)
  end

  def fetch(socket) do
    assign(socket, %{
      messages: Chat.list_messages(),
      changeset: Chat.change_message(%Message{})
    })
  end

  def handle_event("validate", %{"message" => params}, socket) do
    changeset =
      %Message{}
      |> Chat.change_message(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("send_message", %{"message" => params}, socket) do
    case Chat.create_message(params) do
      {:ok, _message} ->
        {:noreply, fetch(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({Chat, [:message, _event_type], _message}, socket) do
    {:noreply, fetch(socket)}
  end
end
