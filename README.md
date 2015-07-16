HelloTestServer [![Build Status](https://travis-ci.org/travelping/hello_test_server.svg)](https://travis-ci.org/travelping/hello_test_server)
=============

A test service using [hello](https://github.com/travelping/hello): 
There are 3 answers type:

1. "pong" on a "ping".
2. Replies json from `priv/replies`/METHOD/* (round-robin)
3. You can write you own method handler. For method `foo.bar` it will be `priv/replies/foo.bar.ex` and look like:
```elixir
case params do
  %{"key" => 1} -> "response"
  %{"key" => 2} -> "response2"
  _ -> %{"error": "unknown"}
end
``` 

## Running

    $> iex -S mix

## Building

Minimal requirements are:

* erlang >= 17 (better 17.5)
* elixir >= 1.0 (1.1.0-dev)
* Apple Bonjour or a compatible API such as Avahi with it's compatibility layer along with the appropriate development files:
    * OS X - bundled
    * Windows - Bonjour SDK
    * BSD/Linux - search for Avahi in your operating systems software manager

If you install erlang on Ubuntu, install aditionally:

* erlang-parsetools
* erlang-eunit

And then:

    $> mix do deps.get, compile


There are a little bit tests:

    $> mix test
