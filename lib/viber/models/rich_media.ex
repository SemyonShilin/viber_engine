defmodule Engine.Viber.Model.RichMedia do
  @moduledoc """
  This object represents a message.
  """

  use Construct
  alias Engine.Viber.Model.Button

  structure do
    field(:Type, :string, default: "rich_media")
    field(:ButtonsGroupColumns, :integer, default: 6)
    field(:ButtonsGroupRows, :integer, default: 7)
    field(:BgColor, :string, default: "#FFFFFF")
    field(:Type, :string, default: "rich_media")
    field(:Buttons, {:array, Button}, default: [])
  end
end
