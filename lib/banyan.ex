defmodule Banyan do
  use Application

  @impl true
  def start(_type, _args) do
    query = DnsQuestion.build_query("www.example.com", 1)
    # todo: add error handling here
    {:ok, socket} = :gen_udp.open(0, [{:active, false}])
    :gen_udp.send(socket, {8, 8, 8, 8}, 53, query)
    # UDP DNS responses are usually less than 512 bytes so reading 1024 bytes is enough
    # see https://www.netmeister.org/blog/dns-size.html
    {:ok, response} = :gen_udp.recv(socket, 1024)
    # https://www.erlang.org/doc/man/gen_udp.html#recv-2
    {_addr, _port, packet} = response
    bytes = Enum.into(packet, <<>>, fn byte -> <<byte::8>> end)

    IO.inspect(bytes)
    IO.inspect(DnsPacket.parse(bytes))
    {:ok, self()}
  end
end
