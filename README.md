# KrDict

**TODO: Add description**

## What I was doing last
Trying to get find to:
* Change the Trie api to match the map api
* Think about allowing spaces and numbers to exist in words.  Basically it's super fragile to anything that is not hangul
* Get prefix search working -> rewrite using new find
* Get dict loader working
* How to handle adding a meaning
* Find a good dictionary


Next order of bizness is to implement prefix search

Next is to get this all connected with the hangul decomposer and recomposer

## Installation

If [available in Hex] (Ehttps://hex.pm/docs/publish), the package can be installed
by adding `kr_dict` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kr_dict, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kr_dict](https://hexdocs.pm/kr_dict).

