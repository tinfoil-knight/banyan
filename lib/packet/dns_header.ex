defmodule DnsHeader do
  defstruct id: 0,
            flags: 0,
            num_questions: 0,
            num_answers: 0,
            num_authorities: 0,
            num_additionals: 0

  # Header section format - https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.1
  @type t :: %DnsHeader{
          # ID
          id: integer,
          # QR, OPCODE, AA, TC, RD, RA, Z, RCODE flags
          flags: integer,
          # QDCOUNT
          num_questions: integer,
          # ANCOUNT
          num_answers: integer,
          # NSCOUNT
          num_authorities: integer,
          # ARCOUNT
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

  def parse(header) do
    <<id::2*8, flags::2*8, num_questions::2*8, num_answers::2*8, num_authorities::2*8,
      num_additionals::2*8>> = header

    %DnsHeader{
      id: id,
      flags: flags,
      num_questions: num_questions,
      num_answers: num_answers,
      num_authorities: num_authorities,
      num_additionals: num_additionals
    }
  end
end
