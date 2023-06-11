defmodule DnsRecord do
  defstruct name: nil, type: nil, class: nil, ttl: nil, data: nil

  @type t :: %DnsRecord{
          name: binary,
          type: integer,
          class: integer,
          ttl: integer,
          data: binary
        }

  # todo: verify this
  def decode_name(data, pos, parts \\ []) do
    <<_::pos*8, byte, rest::binary>> = data

    if byte == 0 do
      {pos, Enum.join(parts, ".")}
    else
      length = byte

      {new_pos, part} =
        case <<length>> do
          # decode compressed name
          # Message compression: https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.4
          <<1::1, 1::1, a::6>> ->
            <<b, _::binary>> = rest
            <<jump_pos::2*8>> = <<(<<0::size(2)>>), (<<a::size(6)>>)>> <> <<b>>
            # length byte + next byte
            curr_pos = pos + 2
            {_p, part} = decode_name(data, jump_pos)
            {curr_pos, part}

          _ ->
            <<part::binary-size(length), _::binary>> = rest
            {pos + 1 + length, part}
        end

      decode_name(data, new_pos, parts ++ [part])
    end
  end

  def parse(data, pos) do
    {read_pos, name} = decode_name(data, pos)

    <<_::read_pos*8, type::2*8, class::2*8, ttl::4*8, data_len::2*8, rest::binary>> = data
    <<record_data::data_len*8>> = rest

    %DnsRecord{
      name: name,
      type: type,
      class: class,
      ttl: ttl,
      data: record_data
    }
  end
end
