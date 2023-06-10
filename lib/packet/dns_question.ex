defmodule DnsQuestion do
  defstruct name: nil, type: nil, class: nil

  @type t :: %DnsQuestion{
          # domain name
          name: binary,
          # record type
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

  def encode_dns_name(domain_name) do
    # assumming only ascii chars (eg: "google.com")
    domain_name
    |> String.split(".")
    |> Enum.map(&(<<byte_size(&1)>> <> &1))
    |> Enum.join()
    |> Kernel.<>(<<0>>)
  end

  import Bitwise

  @recursion_desired 1 <<< 8
  # see https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.2
  @type_a 1
  # see https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.4
  @class_i 1

  def build_query(domain_name, record_type) do
    name = DnsQuestion.encode_dns_name(domain_name)
    id = 0..65535 |> Enum.random()
    header = %DnsHeader{id: id, num_questions: 1, flags: @recursion_desired}
    question = %DnsQuestion{name: name, type: record_type, class: @class_i}
    DnsHeader.to_bin(header) <> DnsQuestion.to_bin(question)
  end
end
