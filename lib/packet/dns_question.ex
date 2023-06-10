defmodule DnsQuestion do
  defstruct name: nil, type: nil, class: nil

  @type t :: %DnsQuestion{
          name: binary,
          type: integer,
          class: integer
        }

  def to_bin(%DnsQuestion{} = question) do
    question.name <>
      <<
        question.type::2*8,
        question.class::2*8
      >>
  end
end
