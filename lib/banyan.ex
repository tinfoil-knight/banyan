defmodule Banyan do
  def run() do
    query = DnsQuestion.build_query("www.example.com", 1)
    # todo: add error handling here
    {:ok, socket} = :gen_udp.open(0, [{:active, false}])
    :gen_udp.send(socket, {8, 8, 8, 8}, 53, query)
    # UDP DNS responses are usually less than 512 bytes so reading 1024 bytes is enough
    # see https://www.netmeister.org/blog/dns-size.html
    :gen_udp.recv(socket, 1024)
  end
end
