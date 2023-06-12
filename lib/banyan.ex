defmodule Banyan do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, self()}
  end

  def send_query(ip_addr, domain_name, record_type) do
    query = DnsQuestion.build_query(domain_name, record_type)
    {:ok, socket} = :gen_udp.open(0, [{:active, false}])
    {:ok, host} = :inet.parse_address(to_charlist(ip_addr))
    :gen_udp.send(socket, host, 53, query)
    # UDP DNS responses are usually less than 512 bytes so reading 1024 bytes is enough
    # see https://www.netmeister.org/blog/dns-size.html
    {:ok, recvData} = :gen_udp.recv(socket, 1024)
    {_addr, _port, packet} = recvData
    data = Enum.into(packet, <<>>, fn byte -> <<byte>> end)
    DnsPacket.parse(data)
  end

  @root_ns_ip "198.41.0.4"

  def resolve(domain_name, record_type, nameserver \\ @root_ns_ip) do
    IO.puts("querying #{nameserver} for #{domain_name}")
    response = send_query(nameserver, domain_name, record_type)
    # type == 1 refers to A records
    # type == 2 refers to NS records
    cond do
      answer = Enum.find(response.answers, fn x -> x.type == 1 end) ->
        ip = answer.data
        ip

      additional = Enum.find(response.additionals, fn x -> x.type == 1 end) ->
        nsIP = additional.data
        resolve(domain_name, record_type, nsIP)

      authority = Enum.find(response.authorities, fn x -> x.type == 2 end) ->
        ns_domain = authority.data
        nsIP = resolve(ns_domain, 1)
        resolve(domain_name, record_type, nsIP)

      true ->
        raise("error while resolution")
    end
  end
end
