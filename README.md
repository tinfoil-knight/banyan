# Banyan

A toy DNS resolver I made while learning Elixir.

## Usage

### Pre-requisites

- [Elixir >= 1.14.5](https://elixir-lang.org/)

### Steps

After cloning the repo, run in directory

```shell
iex -S mix
```

In IEX, to lookup the IP address for a domain, run

```
iex> Banyan.resolve("www.facebook.com")
querying 198.41.0.4 for www.facebook.com
querying 192.12.94.30 for www.facebook.com
querying 129.134.30.12 for www.facebook.com
querying 129.134.30.12 for star-mini.c10r.facebook.com
querying 185.89.219.11 for star-mini.c10r.facebook.com
"157.240.16.35"
```

Note: Only A, NS & CNAME records are supported currently.

## Author

- Kunal Kundu - [@tinfoil-knight](https://github.com/tinfoil-knight)

## License

Distributed under the MIT License. See [LICENSE](./LICENSE) for more information.

## Acknowledgements

- [Implement DNS in a Weekend](https://jvns.ca/blog/2023/05/12/introducing-implement-dns-in-a-weekend/) by [Julia Evans](https://github.com/jvns)
- [Building a DNS server in Rust](https://github.com/EmilHernvall/dnsguide) by [Emil Hernvall](https://github.com/EmilHernvall)
