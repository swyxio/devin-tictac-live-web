defmodule TictacLive.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias TictacLive.Repo

  alias TictacLive.Game.Board

  # Initializes the game board with an empty state
  def init_board do
    %Board{
      board_state: %{
        1 => %{1 => nil, 2 => nil, 3 => nil},
        2 => %{1 => nil, 2 => nil, 3 => nil},
        3 => %{1 => nil, 2 => nil, 3 => nil}
      },
      player_x: nil,
      player_o: nil,
      current_player: "X",
      winner: nil
    }
  end

  # Marks a cell on the board with the current player's symbol (X or O) if the cell is empty
  def mark(%Board{board_state: board_state} = board, row, col, symbol) do
    if Map.get(Map.get(board_state, row), col) == nil do
      updated_board_state = update_in(board_state[row][col], fn _ -> symbol end)
      {:ok, %{board | board_state: updated_board_state}}
    else
      {:error, :cell_already_marked}
    end
  end

  # Checks the board state to determine if there is a winner, a draw, or if the game should continue
  def check_winner(%Board{board_state: board_state}) do
    case check_rows(board_state) || check_columns(board_state) || check_diagonals(board_state) do
      nil ->
        if Enum.any?(board_state, fn {_k, v} -> nil in Map.values(v) end) do
          :continue
        else
          :draw
        end
      winner -> {:winner, winner}
    end
  end

  defp check_rows(board_state) do
    Enum.find_value(board_state, fn {_k, row} ->
      case Enum.uniq(Map.values(row)) do
        [symbol] when symbol in ["X", "O"] -> symbol
        _ -> nil
      end
    end)
  end

  defp check_columns(board_state) do
    1..3
    |> Enum.map(fn col -> Enum.map(board_state, fn {_k, row} -> row[col] end) end)
    |> Enum.find_value(fn column ->
      case Enum.uniq(column) do
        [symbol] when symbol in ["X", "O"] -> symbol
        _ -> nil
      end
    end)
  end

  defp check_diagonals(board_state) do
    diagonals = [
      Enum.with_index(Map.values(board_state))
      |> Enum.map(fn {row, idx} -> row[idx + 1] end),
      Enum.with_index(Map.values(board_state))
      |> Enum.map(fn {row, idx} -> row[3 - idx] end)
    ]

    Enum.find_value(diagonals, fn diagonal ->
      case Enum.uniq(diagonal) do
        [symbol] when symbol in ["X", "O"] -> symbol
        _ -> nil
      end
    end)
  end

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    Repo.all(Board)
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123)
      %Board{}

      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id), do: Repo.get!(Board, id)

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end
end
