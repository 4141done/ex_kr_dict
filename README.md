# KrDict

Currently this is kind of a playground to experiment with tools for working with Korean in Elixir.

This project borrows liberally from [open-korean-text](https://github.com/open-korean-text/open-korean-text). In some cases there is some directly ported code (`KrDict.Util.Hangul`).

## Todo
* https://en.wikipedia.org/wiki/Suffix_array
* https://en.wikipedia.org/wiki/Burrows%E2%80%93Wheeler_transform
* https://en.wikipedia.org/wiki/FM-index
* Make the prefix search more efficient by passing the current place in the node and modifying the query
* How to handle adding a meaning
* Add search frequency to the trie
* Find a good dictionary
* Create struct structure for a sentence that holds "segments" as they are expanded by processing and splitting.  This would likely be a map of arbitrarilty assigned keys to "segments", then a list of keys to show order


## Stemming notes
* By doing basic strategy of removing syllables from the end and then performing a prefix search reliably performs at about 50% accuracy depending on the text
* This strategy is highly susceptible to how
  1. Complete
  2. Tailored
  The dictionary is.

* Next strategies to try:
  1. Find a really good dictionary
  2. Try stemming by deconstructing instead of syllable by syllable
  3. Create additional pipelines for words not found in dictionary
  4. Smarter strategies for choosing matches
    * Can't be longer than original word? (might have some issues there)
    * Can't have too large a difference in length?
    * Partial POS tagging to know whether we prefer 다 at the end since we think it's a verb
  5. What are the mechanisms to help this thing learn as we use it. (Manual submission?)


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

