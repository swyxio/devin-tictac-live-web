defmodule TictacLiveWeb.BoardLive.Index do
  use TictacLiveWeb, :live_view

  alias TictacLive.Game
  alias TictacLive.Game.Board

  @impl true
  def mount(_params, _session, socket) do
    # Initialize the game state here
    {:ok, assign(socket, board: Game.init_board(), game_over: false, winner: nil, current_player: "X")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Board")
    |> assign(:board, Game.get_board!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Board")
    |> assign(:board, %Board{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Boards")
    |> assign(:board, Game.init_board()) # Ensure board is initialized for the index action
  end

  @impl true
  def handle_info({TictacLiveWeb.BoardLive.FormComponent, {:saved, board}}, socket) do
    {:noreply, stream_insert(socket, :boards, board)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    board = Game.get_board!(id)
    {:ok, _} = Game.delete_board(board)

    {:noreply, stream_delete(socket, :boards, board)}
  end

  @impl true
  def handle_event("mark", %{"row" => row, "col" => col}, socket) do
    # Handle the mark event, update the board, and broadcast changes
    case Game.mark(socket.assigns.board, row, col, socket.assigns.current_player) do
      {:ok, board} ->
        # Check if the game is over
        case Game.check_winner(board) do
          {:winner, winner} ->
            {:noreply, assign(socket, board: board, game_over: true, winner: winner)}
          :draw ->
            {:noreply, assign(socket, board: board, game_over: true, winner: "Draw")}
          :continue ->
            # Switch the current player and continue the game
            new_player = if socket.assigns.current_player == "X", do: "O", else: "X"
            {:noreply, assign(socket, board: board, current_player: new_player)}
        end
      {:error, _reason} ->
        # If there's an error (e.g., cell already marked), do not update the board
        {:noreply, socket}
    end
  end
end
