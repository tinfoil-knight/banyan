defmodule DnsHeader do
  defstruct id: 0,
            flags: 0,
            num_questions: 0,
            num_answers: 0,
            num_authorities: 0,
            num_additionals: 0

  @type t :: %DnsHeader{
          id: integer,
          flags: integer,
          num_questions: integer,
          num_answers: integer,
          num_authorities: integer,
          num_additionals: integer
        }

  def to_bin(%DnsHeader{} = header) do
    <<
      header.id::2*8,
      header.flags::2*8,
      header.num_questions::2*8,
      header.num_answers::2*8,
      header.num_authorities::2*8,
      header.num_additionals::2*8
    >>
  end
end
