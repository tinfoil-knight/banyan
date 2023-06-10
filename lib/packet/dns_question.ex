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
end
