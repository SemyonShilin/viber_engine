defmodule Engine.Viber.Model.Button do
  @moduledoc """
  This object represents a message.
  """

  use Construct

  structure do
    field :Columns, :integer, default: 0
    field :Rows, :integer, default: 0
    field :ActionType, :string
    field :ActionBody, :string, default: ""
    field :Text, :string
    field :TextSize, :string, default: "medium"
    field :TextVAlign, :string, default: "middle"
    field :TextHAlign, :string, default: "middle"
    field :Image, :string, default: ""
  end
end
