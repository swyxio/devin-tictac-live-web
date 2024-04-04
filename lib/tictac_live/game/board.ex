defmodule TictacLive.Game.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :board_state, :map
    field :current_player, :string
    field :player_o, :string
    field :player_x, :string
    field :winner, :string, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:player_x, :player_o, :current_player, :board_state, :winner])
    |> validate_required([:player_x, :player_o, :current_player])
  end
end
