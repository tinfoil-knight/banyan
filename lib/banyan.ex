defmodule Banyan do
  use Application

  @impl true
  def start(_type, _args) do
    # ip = lookup_domain("metafilter.com")
    # IO.inspect(ip)
    parsed = send_query("198.41.0.4", "google.com", 1)
    IO.inspect(parsed)
    {:ok, self()}
  end

  def lookup_domain(domain_name) do
    # note: only handles responses with A records properly
    query = DnsQuestion.build_query(domain_name)
    # todo: add error handling here
    {:ok, socket} = :gen_udp.open(0, [{:active, false}])
    :gen_udp.send(socket, {8, 8, 8, 8}, 53, query)
    # UDP DNS responses are usually less than 512 bytes so reading 1024 bytes is enough
    # see https://www.netmeister.org/blog/dns-size.html
    {:ok, recvData} = :gen_udp.recv(socket, 1024)
    # https://www.erlang.org/doc/man/gen_udp.html#recv-2
    {_addr, _port, packet} = recvData
    data = Enum.into(packet, <<>>, fn byte -> <<byte::8>> end)
    parsed = DnsPacket.parse(data)
    ip = Enum.join(:binary.bin_to_list(<<Enum.at(parsed.answers, 0).data::4*8>>), ".")
    ip
  end

  def send_query(ip_addr, domain_name, record_type) do
    query = DnsQuestion.build_query(domain_name, record_type)
    {:ok, socket} = :gen_udp.open(0, [{:active, false}])
    {:ok, host} = :inet.parse_address(to_charlist(ip_addr))
    :gen_udp.send(socket, host, 53, query)
    {:ok, recvData} = :gen_udp.recv(socket, 1024)
    {_addr, _port, packet} = recvData
    data = Enum.into(packet, <<>>, fn byte -> <<byte>> end)
    DnsPacket.parse(data)
  end
end
