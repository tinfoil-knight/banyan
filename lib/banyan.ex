defmodule Banyan do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, self()}
  end

  @dns_port 53

  defp send_query(ip_addr, domain_name, record_type) do
    query = Question.build_query(domain_name, record_type)
    {:ok, socket} = :gen_udp.open(0, [{:active, false}])
    {:ok, host} = :inet.parse_address(to_charlist(ip_addr))
    :gen_udp.send(socket, host, @dns_port, query)
    # UDP DNS responses are usually less than 512 bytes so reading 1024 bytes is enough
    # see https://www.netmeister.org/blog/dns-size.html
    {:ok, recvData} = :gen_udp.recv(socket, 1024)
    {_addr, _port, packet} = recvData
    data = Enum.into(packet, <<>>, fn byte -> <<byte>> end)
    Packet.parse(data)
  end

  @root_ns_ip "198.41.0.4"

  def resolve(domain_name, record_type \\ "A") do
    case Record.type_n2v(record_type) do
      nil ->
        raise("unsupported record type: #{record_type}")

      v ->
        resolve_helper(domain_name, v)
    end
  end

  defp resolve_helper(domain_name, record_type, nameserver \\ @root_ns_ip) do
    IO.puts("querying #{nameserver} for #{domain_name}")
    response = send_query(nameserver, domain_name, record_type)

    cond do
      answer = Enum.find(response.answers, &Record.match_type(&1.type, "A")) ->
        ip = answer.data
        ip

      additional = Enum.find(response.additionals, &Record.match_type(&1.type, "A")) ->
        nsIP = additional.data
        resolve_helper(domain_name, record_type, nsIP)

      authority = Enum.find(response.authorities, &Record.match_type(&1.type, "NS")) ->
        ns_domain = authority.data
        nsIP = resolve(ns_domain, "A")
        resolve_helper(domain_name, record_type, nsIP)

      answer = Enum.find(response.answers, &Record.match_type(&1.type, "CNAME")) ->
        cname = answer.data
        resolve_helper(cname, record_type, nameserver)

      true ->
        IO.puts("ns:#{nameserver}")
        IO.inspect(response)
        raise("error while resolution")
    end
  end
end
