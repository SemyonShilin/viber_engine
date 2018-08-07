defmodule Engine.Viber.Model.RichMedia do
  @moduledoc """
  This object represents a message.
  """

  use Construct
  alias Engine.Viber.Model.Button

  structure do
    field :Type, :string, default: "rich_media"
    field :ButtonsGroupColumns, :int, default: 0
    field :ButtonsGroupRows, :int, default: 0
    field :BgColor, :string, default: "#FFFFFF"
    field :Type, :string, default: "rich_media"
    field :Buttons, {:array, {:array, Button}}, default: []
  end
end
