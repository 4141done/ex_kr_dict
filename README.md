# KrDict

Currently this is kind of a playground to experiment with tools for working with Korean in Elixir.

This project borrows liberally from [open-korean-text](https://github.com/open-korean-text/open-korean-text). In some cases there is some directly ported code (`KrDict.Util.Hangul`).

## Todo
* Make the prefix search more efficient by passing the current place in the node and modifying the query
* Measure individual "letters" vs syllables as the base element of the trie (syllables seem much better)
* How to handle adding a meaning
* Add search frequency to the trie
* Find a good dictionary
* Start playing with sample texts


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

