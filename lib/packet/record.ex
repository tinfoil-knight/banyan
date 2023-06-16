defmodule Record do
  defstruct name: nil, type: nil, class: nil, ttl: nil, data: nil

  @type t :: %Record{
          name: binary,
          type: integer,
          class: integer,
          ttl: integer,
          data: binary
        }

  def decode_name(data, pos, parts \\ []) do
    <<_::pos*8, byte, rest::binary>> = data
    # todo: refactor this

    case <<byte>> do
      <<0>> ->
        {pos + 1, Enum.join(parts, ".")}

      <<1::1, 1::1, a::6>> ->
        # decode compressed name
        # Message compression: https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.4
        <<b, _::binary>> = rest
        <<jump_pos::2*8>> = <<(<<0::size(2)>>), (<<a::size(6)>>)>> <> <<b>>
        # length byte + next byte
        curr_pos = pos + 2
        {_p, part} = decode_name(data, jump_pos, [])
        {curr_pos, Enum.join(parts ++ [part], ".")}

      <<length>> ->
        <<part::binary-size(length), _::binary>> = rest
        decode_name(data, pos + 1 + length, parts ++ [part])
    end
  end

  def parse(data, pos) do
    {read_pos, name} = decode_name(data, pos)
    <<_::read_pos*8, type::2*8, class::2*8, ttl::4*8, data_len::2*8, rest::binary>> = data

    {new_pos, record_data} =
      case type_v2n(type) do
        "A" ->
          <<ret::data_len*8, _::binary>> = rest
          ip = Enum.join(:binary.bin_to_list(<<ret::4*8>>), ".")
          {read_pos + (10 + data_len), ip}

        "NS" ->
          decode_name(data, read_pos + 10)

        "CNAME" ->
          decode_name(data, read_pos + 10)

        _ ->
          {read_pos + (10 + data_len), rest}
      end

    {
      %Record{
        name: name,
        type: type,
        class: class,
        ttl: ttl,
        data: record_data
      },
      new_pos
    }
  end

  # https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.2
  @val_to_name %{1 => "A", 2 => "NS", 5 => "CNAME"}
  @name_to_val Map.new(@val_to_name, fn {k, v} -> {v, k} end)

  def type_n2v(name) do
    Map.get(@name_to_val, name, nil)
  end

  def type_v2n(val) do
    Map.get(@val_to_name, val, nil)
  end

  def match_type(to_match, match_with_type) do
    case Map.get(@name_to_val, match_with_type, nil) do
      nil -> false
      v -> to_match == v
    end
  end
end
