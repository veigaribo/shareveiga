defmodule Shareveiga2Core.Storage do
  use GenServer

  @text_id 2013

  @impl true
  def init(:ok) do
    :mnesia.create_schema([node()])
    :mnesia.start()
    :mnesia.create_table(:text, attributes: [:id, :content], disc_copies: [node()])
    :mnesia.wait_for_tables([:text], :infinity)

    :mnesia.transaction(fn ->
      result = :mnesia.read({:text, @text_id})

      case result do
        [] -> :mnesia.write({:text, @text_id, ""})
      end
    end)

    {:ok, nil}
  end

  @impl true
  def handle_call(:get, _from, nil) do
    {:atomic, result} =
      :mnesia.transaction(fn ->
        :mnesia.read({:text, @text_id})
      end)

    [{:text, @text_id, text}] = result

    {:reply, text, nil}
  end

  @impl true
  def handle_cast({:set, new_text}, nil) do
    text_record = {:text, @text_id, new_text}

    :mnesia.transaction(fn ->
      :mnesia.write(text_record)
    end)

    {:noreply, nil}
  end

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: :storage])
  end

  def get() do
    GenServer.call(:storage, :get)
  end

  def set(text) do
    GenServer.cast(:storage, {:set, text})
  end
end
